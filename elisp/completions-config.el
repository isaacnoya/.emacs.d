;;; `completions-config.el' --- Configuration related to completions  -*- lexical-binding: t; -*-

(use-package which-key
  :ensure t
  :straight t
  :defer t
  :hook
  (after-init . which-key-mode))

(use-package swiper
  :ensure t
  :straight t)

(use-package ivy
  :ensure t
  :straight t
  :diminish
  :bind
  (("C-s" . swiper-isearch)
   :map ivy-minibuffer-map
   ("TAB" . ivy-alt-done)
   :map ivy-switch-buffer-map
   ("C-d" . ivy-switch-buffer-kill)
   :map ivy-reverse-i-search-map
   ("C-d" . ivy-reverse-i-search-kill)))
(require 'ivy)
(ivy-mode 1)

(use-package orderless
  :ensure t
  :straight t
  :defer t
  :after ivy
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :ensure t
  :straight t
  :hook
  (after-init . marginalia-mode))

(use-package corfu
  :ensure t
  :straight t
  :defer t
  :hook
  ((prog-mode . corfu-mode)
   (ciao-mode . corfu-mode)
   (ciao-inferior-mode . corfu-mode))
  :bind (:map corfu-map
              ("TAB" . corfu-complete)
              ([tab] . corfu-complete))
  :custom
  (corfu-enable-in-minibuffer nil)
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-quit-no-match t)
  (corfu-scroll-margin 5)
  (corfu-max-width 50)
  (corfu-min-width 50)
  (corfu-popupinfo-delay 0.5)
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)
  :init
  (setq corfu-auto-delay 0.15
        corfu-auto-prefix 2)
  (corfu-popupinfo-mode t))

(use-package nerd-icons-corfu
  :ensure t
  :straight t
  :defer t
  :after (:all corfu))

(use-package cape
  :ensure t
  :straight t
  :defer t
  :commands (cape-file cape-dabbrev cape-keyword cape-capf-super)
  :preface
  (defun kj/code-completion-capfs ()
    "Add generic completion sources for code buffers."
    (add-hook 'completion-at-point-functions #'cape-file t t)
    (add-hook 'completion-at-point-functions
              (cape-capf-super #'cape-dabbrev #'cape-keyword)
              t t))
  :hook
  ((prog-mode . kj/code-completion-capfs)
   (ciao-mode . kj/code-completion-capfs)
   (ciao-inferior-mode . kj/code-completion-capfs)))

(use-package minuet
  :ensure t
  :straight t
  :defer t
  :hook
  ((prog-mode . minuet-auto-suggestion-mode)
   (ciao-mode . minuet-auto-suggestion-mode)
   (ciao-inferior-mode . minuet-auto-suggestion-mode))
  :bind
  (("C-c i i" . minuet-show-suggestion)
   ("C-c i m" . minuet-complete-with-minibuffer)
   ("C-c i c" . minuet-configure-provider)
   :map minuet-active-mode-map
   ("M-n" . minuet-next-suggestion)
   ("M-p" . minuet-previous-suggestion)
   ("M-a" . minuet-accept-suggestion)
   ("M-e" . minuet-dismiss-suggestion))
  :config
  (setq minuet-provider 'openai
        minuet-request-timeout 3.0
        minuet-auto-suggestion-throttle-delay 1.2
        minuet-auto-suggestion-debounce-delay 0.5
        minuet-n-completions 1)
  (plist-put minuet-openai-options :model "gpt-5.6-luna")
  (plist-put minuet-openai-options :api-key "OPENAI_API_KEY")
  (minuet-set-optional-options minuet-openai-options
                               :max_completion_tokens 96)
  (minuet-set-optional-options minuet-openai-options
                               :reasoning_effort "none"))

;; Provide ourselves
(provide 'completions-config)

;;; `completions-config.el' ends here
