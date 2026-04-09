;;; `early-init.el' --- Configurations before init.el  -*- lexical-binding: t; -*-

(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(undecorated-round . t)))

;;; `early-init.el' ends here
