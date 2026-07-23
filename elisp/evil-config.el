;;; evil-config.el --- Evil mode configuration  -*- lexical-binding: t; -*-

;; Evil mode
(use-package evil
  :ensure t
  :straight t
  :defer t
  :functions (evil-global-set-key
              evil-set-initial-state)
  :defines (evil-insert-state-map)
  :hook
  (after-init . evil-mode)
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-fine-undo t
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil)
  :config
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; (define-key evil-normal-state-map (kbd "C-d")
  ;;   		  (lambda ()
  ;;   			(evil-scroll-down 0)
  ;;   			(evil-scroll-line-to-center nil)))
  ;; (define-key evil-visual-state-map (kbd "C-d")
  ;;   		  (lambda ()
  ;;   			(evil-scroll-down 0)
  ;;   			(evil-scroll-line-to-center nil)))
  ;; (define-key evil-normal-state-map (kbd "C-u")
  ;;   		  (lambda ()
  ;;   			(evil-scroll-up 0)
  ;;   			(evil-scroll-line-to-center nil)))
  ;; (define-key evil-visual-state-map (kbd "C-u")
  ;;   		  (lambda ()
  ;;   			(evil-scroll-up 0)
  ;;   			(evil-scroll-line-to-center nil)))

  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'pdf-view-mode 'normal)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)
  (evil-mode 1))

;; Useful collection
(use-package evil-collection
  :defer t
  :ensure t
  :straight t
  :after evil
  :custom
  (evil-collection-outline-bind-tab-p t)
  (evil-collection-want-find-usages-bindings t)
  :hook
  (evil-mode . evil-collection-init))

;; Disable RET, TAB, and SPC from evil maps
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil)
  (define-key evil-motion-state-map (kbd "SPC") nil))

;; Provide ourselves
(provide 'evil-config)

;;; evil-config.el ends here
