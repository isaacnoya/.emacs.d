;;; `my-functions.el' --- My own functions  -*- lexical-binding: t; -*-

(declare-function evil-emacs-state "evil-states")
(declare-function evil-normal-state "evil-states")

(defun my/get-pwd (&rest keys)
  "Decrypt a password"
  (let ((result (apply #'auth-source-search keys)))
    (if result
        (funcall (plist-get (car result) :secret))
      nil)))

(defun bootstrap-shell-path ()
  "Bootstrap my shell's PATH into Emacs"
  (let* ((shell-path-string (string-trim
                            (shell-command-to-string
                             "$SHELL --login -i -c 'printf \"%s\" $PATH'")))
         (path-list (split-string shell-path-string path-separator t)))
    (setenv "PATH" (string-join path-list path-separator))
    (setq exec-path path-list)))

;; Local vars
(defvar presentation-mode-active nil
  "A variable to keep track wether presentation mode is active.")
(defvar saved-background-color nil
  "Current background color.")

;; Slides presentation
(defun my/slides-presentation ()
  "Sets presentation mode for the current buffer, in case that it's a
pdf-view-mode buffer"
  (interactive)
  (if (and (only-one-buffer-in-frame-p) (eq major-mode 'pdf-view-mode))
      (toggle-presentation-mode-setup)
    (message "Not in a single buffer with pdf-view-mode!")))

;; Helper functions
(defun only-one-buffer-in-frame-p ()
  "Return t if there is only one buffer displayed in the current frame, nil
otherwise."
  (let ((buffers (mapcar #'window-buffer (window-list))))
    (eq (length (delete-dups buffers)) 1)))

(defun toggle-background-color ()
  (if saved-background-color
      (progn
        (set-face-background 'default saved-background-color)
        (setq saved-background-color nil))
    (progn
      (setq saved-background-color (face-attribute 'default :background))
      (set-face-background 'default "black"))))

(defun toggle-presentation-mode-setup ()
  "Toggles presentation mode: Disable mode-line and evil-mode"
  (if presentation-mode-active
      (progn
        (setq mode-line-format t)
        (doom-modeline-mode)
        (evil-normal-state))
    (progn
      (doom-modeline-mode)
      (setq mode-line-format nil)
      (evil-emacs-state)))
  (toggle-background-color)
  (execute-kbd-macro (kbd "<f11>"))
  (setq presentation-mode-active (not presentation-mode-active)))

;; Provide ourselves
(provide 'my-functions)

;;; `my-functions.el' ends here
