;;; rust-debug-config.el --- Rust debugging with Cargo and LLDB -*- lexical-binding: t; -*-

;;; Commentary:
;; `my-rust-debug' builds a Cargo binary before launching it through dap-mode.
;; `my-fvkg-debug' supplies this project's example arguments for a first session.

;;; Code:

(require 'cl-lib)
(require 'compile)
(require 'json)
(require 'subr-x)
(require 'dap-lldb)
(require 'dap-ui)

;; GUI Emacs may not inherit the shell's Rustup path.
(let ((cargo-bin (expand-file-name "~/.cargo/bin")))
  (when (file-directory-p cargo-bin)
    (add-to-list 'exec-path cargo-bin)
    (unless (member cargo-bin (parse-colon-path (getenv "PATH")))
      (setenv "PATH" (concat cargo-bin path-separator (getenv "PATH"))))))

(defcustom my-rust-debug-load-formatters nil
  "Whether to load the active Rust toolchain's LLDB formatters.
Leave nil if Apple's lldb-dap stops responding when displaying locals.
Raw variables remain available without these Python formatters.
Changes apply to the next debug session."
  :type 'boolean
  :group 'dap-mode)

(defvar my-rust-debug-arguments-history nil
  "History of arguments entered for Rust debug sessions.")

(defconst my-fvkg-debug-example-arguments
  "query run tests/fixtures/execution/ tests/fixtures/execution/query.rq --format text"
  "Example FvKG arguments, using a directory of RML mappings.")

(defun my-rust-debug--adapter ()
  "Find the LLDB debug adapter, including Apple's developer tools."
  (or (executable-find "lldb-dap")
      (when (executable-find "xcrun")
        (with-temp-buffer
          (when (zerop (process-file "xcrun" nil t nil "--find" "lldb-dap"))
            (let ((path (string-trim (buffer-string))))
              (when (file-executable-p path) path)))))
      (executable-find "lldb-vscode")
      (user-error "Cannot find lldb-dap; check your LLDB installation")))

(defun my-rust-debug--metadata ()
  "Read Cargo metadata for `default-directory' without resolving dependencies."
  (with-temp-buffer
    (unless (zerop (process-file "cargo" nil t nil
                                "metadata" "--no-deps" "--format-version" "1"))
      (user-error "Cargo metadata failed: %s" (string-trim (buffer-string))))
    (goto-char (point-min))
    (json-parse-buffer :object-type 'plist :array-type 'list
                       :null-object nil :false-object nil)))

(defun my-rust-debug--init-commands ()
  "Optionally load the current toolchain's Rust formatters.
Return an empty JSON array by default to avoid formatter hangs in LLDB."
  (if (not my-rust-debug-load-formatters)
      []
    (let* ((sysroot (string-trim (car (process-lines "rustc" "--print" "sysroot"))))
           (etc (expand-file-name "lib/rustlib/etc/" sysroot))
           (lookup (expand-file-name "lldb_lookup.py" etc))
           (commands (expand-file-name "lldb_commands" etc)))
      (unless (file-readable-p lookup)
        (user-error "Rust LLDB formatters are missing: %s" lookup))
      (vconcat
       (list (format "command script import %S" lookup))
       ;; Older Rust toolchains register their formatters in this separate file.
       (when (file-readable-p commands)
         (list (format "command source %S" commands)))))))

(defun my-rust-debug--with-path-mapping (configuration)
  "Match CONFIGURATION's editor paths to the physical paths in debug symbols.
Keep source navigation in the project's original path, including symlinks."
  (let* ((root (file-name-as-directory
                (expand-file-name (plist-get configuration :cwd))))
         (physical-root (file-truename root)))
    (setq configuration
          (plist-put configuration :local-to-remote-path-fn #'file-truename))
    (plist-put
     configuration :remote-to-local-path-fn
     (lambda (path)
       (if (and (stringp path) (string-prefix-p physical-root path))
           (expand-file-name (file-relative-name path physical-root) root)
         path)))))

(defun my-rust-debug (&optional binary arguments)
  "Build and debug a Cargo BINARY, prompting for its command-line ARGUMENTS.
Arguments use shell-style quoting, so paths containing spaces can be quoted.
The build runs asynchronously; a failed build never starts the debugger."
  (interactive)
  (let* ((root (expand-file-name
                (or (locate-dominating-file default-directory "Cargo.toml")
                    (user-error "Open a file inside a Cargo project first"))))
         (default-directory root)
         (metadata (my-rust-debug--metadata))
         (packages (plist-get metadata :packages))
         (binaries
          (or (delete-dups
               (cl-loop for package in packages append
                        (cl-loop for target in (plist-get package :targets)
                                 when (member "bin" (plist-get target :kind))
                                 collect (plist-get target :name))))
              (user-error "This Cargo project has no binary targets")))
         (default-binary
          (or (cl-loop for package in packages
                       thereis (plist-get package :default_run))
              (car binaries)))
         (binary (or binary
                     (if (length= binaries 1)
                         (car binaries)
                       (completing-read "Cargo binary: " binaries nil t
                                        nil nil default-binary))))
         (arguments
          (or arguments
              (read-shell-command "Program arguments: "
                                  (car my-rust-debug-arguments-history)
                                  'my-rust-debug-arguments-history))))
    (unless (member binary binaries)
      (user-error "No Cargo binary named %s in this project" binary))
    (setq dap-lldb-debug-program (list (my-rust-debug--adapter)))
    (let ((configuration
           (my-rust-debug--with-path-mapping
            (list :type "lldb-vscode"
                 :request "launch"
                 :name (format "Rust :: %s" binary)
                 :program (expand-file-name
                           (concat "debug/" binary)
                           (plist-get metadata :target_directory))
                 :cwd root
                 :args (vconcat (split-string-shell-command arguments))
                 :initCommands (my-rust-debug--init-commands)
                 :stopOnEntry :json-false)))
          (command (mapconcat #'shell-quote-argument
                              (list (or (executable-find "cargo") "cargo")
                                    "build" "--bin" binary)
                              " ")))
      (save-some-buffers
       nil (lambda ()
             (and buffer-file-name
                  (string-prefix-p root (expand-file-name buffer-file-name)))))
      (dap-mode 1)
      (let ((buffer (compilation-start
                     command 'compilation-mode
                     (lambda (_) (format "*Rust debug build: %s*" binary)))))
        (cl-labels
            ((finished (build-buffer status)
               (with-current-buffer build-buffer
                 (remove-hook 'compilation-finish-functions #'finished t))
               (if (string= status "finished\n")
                   (let ((default-directory root))
                     (dap-register-debug-template
                      (plist-get configuration :name) configuration)
                     (dap-debug configuration))
                 (message "Rust build failed; see %s" (buffer-name build-buffer)))))
          (with-current-buffer buffer
            (add-hook 'compilation-finish-functions #'finished nil t)))))))

(defun my-fvkg-debug ()
  "Build and debug FvKG, prompting with a working query example."
  (interactive)
  (my-rust-debug
   "fvkg"
   (read-shell-command "FvKG arguments: " my-fvkg-debug-example-arguments
                       'my-rust-debug-arguments-history)))

(provide 'rust-debug-config)
;;; rust-debug-config.el ends here
