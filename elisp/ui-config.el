;;; `ui-config.el' --- UI configuration and packages  -*- lexical-binding: t; -*-

;; Mode-line
(use-package doom-modeline
  :ensure t
  :straight t
  :defer t
  :custom
  (doom-modeline-buffer-file-name-style 'buffer-name)
  (doom-modeline-project-detection 'project)
  (doom-modeline-buffer-name t)
  (doom-modeline-vcs-max-length 25)
  :config
  (setq doom-modeline-icon t)
  :hook
  (after-init . doom-modeline-mode))

(use-package nerd-icons
  :ensure t
  :straight t
  :defer t)

(use-package nerd-icons-dired
  :ensure t
  :straight t
  :defer t
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :ensure t
  :straight t
  :after (:all nerd-icons marginalia)
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package dashboard
  :ensure t
  :straight t
  :custom
  (dashboard-banner-logo-title "Archivos recientes")
  (dashboard-center-content t)
  (dashboard-items '((recents . 10)))
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-show-shortcuts nil)
  (dashboard-startup-banner 'official)
  :config
  (dashboard-setup-startup-hook))

;; Provide ourselves
(provide 'ui-config)

;;; `ui-config.el' ends here
