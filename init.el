;;; `init.el' --- Entrypoint of Emacs config  -*- lexical-binding: t; -*-

;; Update load-path
(add-to-list 'load-path (expand-file-name "elisp" user-emacs-directory))
(add-to-list 'default-frame-alist '(undecorated . t))
;; Require some functions
(require 'my-functions)

;; Bootstrap shell's PATH
(when (display-graphic-p)
  (bootstrap-shell-path))

;; Load the config file
(require 'config)

;; Provide ourselves
(provide 'init)

;;; `init.el' ends here
