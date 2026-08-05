
;;; `codex-config.el' --- Codex IDE integration  -*- lexical-binding: t; -*-

(require 'seq)

(declare-function evil-set-initial-state "evil" (mode state))

(defgroup kj-codex nil
  "Local Codex integration."
  :group 'tools)

(defcustom kj-codex-dispatch-timeout 0.4
  "Seconds to wait for `ñ' after `C-x C-ñ'."
  :type 'float
  :group 'kj-codex)

(defun kj/codex-vscode-cli-candidates ()
  "Return Codex CLI candidates bundled with the VS Code extension."
  (sort (file-expand-wildcards
         (expand-file-name
          ".vscode/extensions/openai.chatgpt-*/bin/*/codex"
          (getenv "HOME")))
        #'string>))

(defun kj/codex-cli-path ()
  "Return the best available Codex CLI path."
  (let* ((path-candidate (executable-find "codex"))
         (vscode-candidate (seq-find #'file-executable-p
                                     (kj/codex-vscode-cli-candidates)))
         (vscode-prefix (expand-file-name
                         ".vscode/extensions/openai.chatgpt-"
                         (getenv "HOME"))))
    (cond
     ((and path-candidate
           (not (string-prefix-p vscode-prefix
                                 (file-truename path-candidate))))
      path-candidate)
     (vscode-candidate)
     (path-candidate)
     (t "codex"))))

(defun kj/codex-refresh-cli-path ()
  "Refresh `codex-ide-cli-path' from the current environment."
  (setq codex-ide-cli-path (kj/codex-cli-path))
  (when (boundp 'codex-ide--cli-available)
    (setq codex-ide--cli-available nil)))

(defun kj/codex-open ()
  "Open Codex IDE for the current project."
  (interactive)
  (kj/codex-refresh-cli-path)
  (codex-ide))

(defun kj/codex-continue ()
  "Continue the latest Codex IDE session for the current project."
  (interactive)
  (kj/codex-refresh-cli-path)
  (codex-ide-continue))

(defun kj/codex-dispatch ()
  "Open Codex IDE, or continue the latest session when followed by `ñ'."
  (interactive)
  (let ((event (read-event nil nil kj-codex-dispatch-timeout)))
    (cond
     ((equal event ?ñ)
      (kj/codex-continue))
     ((equal event ?\C-g)
      (keyboard-quit))
     (t
      (when event
        (push event unread-command-events))
      (kj/codex-open)))))

(use-package codex-ide
  :ensure t
  :straight (:type git :host github :repo "dgillis/emacs-codex-ide")
  :defer t
  :commands (codex-ide codex-ide-continue codex-ide-menu)
  :bind ("C-x C-ñ" . kj/codex-dispatch)
  :init
  (setq codex-ide-cli-path (kj/codex-cli-path))
  :custom
  (codex-ide-new-session-split 'vertical)
  :config
  (with-eval-after-load 'evil
    (evil-set-initial-state 'codex-ide-session-mode 'emacs)))

;; Provide ourselves
(provide 'codex-config)

;;; `codex-config.el' ends here
