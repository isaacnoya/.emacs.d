;;; `early-init.el' --- Configurations before init.el  -*- lexical-binding: t; -*-

;; Avoid libgccjit's incorrect default deployment target on macOS 27.
(when (and (eq system-type 'darwin)
           (not (getenv "MACOSX_DEPLOYMENT_TARGET")))
  (setenv "MACOSX_DEPLOYMENT_TARGET" "27.0"))

;; Let AeroSpace manage macOS frames; keep the native window manageable.
(if (eq system-type 'darwin)
    (progn
      (setq frame-resize-pixelwise t)
      (dolist (parameter '((fullscreen . nil)
                           (undecorated . nil)
                           (undecorated-round . nil)))
        (add-to-list 'initial-frame-alist parameter)
        (add-to-list 'default-frame-alist parameter)))
  (add-to-list 'initial-frame-alist '(fullscreen . maximized))
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  (add-to-list 'default-frame-alist '(undecorated . t)))

;;; `early-init.el' ends here
