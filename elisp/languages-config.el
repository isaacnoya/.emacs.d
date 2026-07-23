;;; `languages-config.el' --- (Programming) languages configuration  -*- lexical-binding: t; -*-

;; CC mode
(use-package cc-mode
  :ensure nil
  :init
  (setq c-default-style "stroustrup")
  (setq c-basic-indent 2)
  (setq c-basic-offset 2))

;; Rust
(use-package rust-mode
  :ensure t
  :straight t
  :init
  (setq rust-basic-indent 2)
  (setq rust-indent-offset 2)
  (setq rust-ts-mode-basic-indent 2)
  (setq rust-ts-mode-indent-offset 2))

;; TypeScript
(use-package typescript-mode
  :ensure t
  :straight t
  :config
  (setq indent-tabs-mode nil))

;; Treesitter
(use-package treesit-auto
  :ensure t
  :straight t
  :after emacs
  :functions (global-treesit-auto-mode)
  :custom
  (treesit-auto-install nil)
  :mode
  (("\\.tsx\\'" . tsx-ts-mode)
   ("\\.js\\'"  . typescript-ts-mode)
   ("\\.mjs\\'" . typescript-ts-mode)
   ("\\.mts\\'" . typescript-ts-mode)
   ("\\.cjs\\'" . typescript-ts-mode)
   ("\\.ts\\'"  . typescript-ts-mode)
   ("\\.jsx\\'" . tsx-ts-mode)
   ("\\.rs\\'" . rust-ts-mode)
   ("\\.json\\'" .  json-ts-mode))
  :init
  (setq treesit-language-source-alist
        '(;; (c          . ("https://github.com/tree-sitter/tree-sitter-c"          "v0.20.7" "src"))
          (haskell    . ("https://github.com/tree-sitter/tree-sitter-haskell"    "master"  "src"))
          (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript" "v0.23.1" "src"))
          (json       . ("https://github.com/tree-sitter/tree-sitter-json"       "v0.24.8" "src"))
          (rust       . ("https://github.com/tree-sitter/tree-sitter-rust"       "v0.23.0" "src"))
          (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "master"  "typescript/src"))))
  :config
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode t))

;; LSP
(use-package lsp-mode
  :ensure t
  :straight t
  :defer t
  :commands (lsp lsp-deferred)
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (lean4-mode . lsp-deferred)
         (java-mode . lsp-deferred)
         (typescript-mode . lsp-deferred))
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-inlay-hint-enable t)
  (lsp-completion-provider :none)
  (lsp-session-file (locate-user-emacs-file ".lsp-session"))
  (lsp-log-io nil)
  (lsp-idle-delay 0.500)
  (lsp-keep-workspace-alive nil)
  ;; Core settings
  (lsp-enable-xref t)
  (lsp-auto-configure t)                                ;; Automatically configure LSP.
  (lsp-enable-links nil)                                ;; Disable links.
  (lsp-eldoc-enable-hover t)                            ;; Enable ElDoc hover.
  (lsp-enable-file-watchers nil)                        ;; Disable file watchers.
  (lsp-enable-folding nil)                              ;; Disable folding.
  (lsp-enable-imenu t)                                  ;; Enable Imenu support.
  (lsp-enable-indentation nil)                          ;; Disable indentation.
  (lsp-enable-on-type-formatting nil)                   ;; Disable on-type formatting.
  (lsp-enable-suggest-server-download t)                ;; Enable server download suggestion.
  (lsp-enable-symbol-highlighting t)                    ;; Enable symbol highlighting.
  (lsp-enable-text-document-color t)                    ;; Enable text document color.
  ;; Modeline settings
  (lsp-modeline-code-actions-enable nil)                ;; Keep modeline clean.
  (lsp-modeline-diagnostics-enable nil)                 ;; Use `flymake' instead.
  (lsp-modeline-workspace-status-enable t)              ;; Display "LSP" in the modeline when enabled.
  (lsp-signature-doc-lines 1)                           ;; Limit echo area to one line.
  (lsp-eldoc-render-all t)                              ;; Render all ElDoc messages.
  ;; Completion settings
  (lsp-completion-enable t)                             ;; Enable completion.
  (lsp-completion-enable-additional-text-edit t)        ;; Enable additional text edits for completions.
  (lsp-enable-snippet nil)                              ;; Disable snippets
  (lsp-completion-show-kind t)                          ;; Show kind in completions.
  ;; Lens settings
  (lsp-lens-enable t)                                   ;; Enable lens support.
  ;; Headerline settings
  (lsp-headerline-breadcrumb-enable nil)                ;; Enable symbol numbers in the headerline.
  ;; Semantic settings
  (lsp-semantic-tokens-enable t))                       ;; Disable semantic tokens.

;; Java
(use-package lsp-java
  :ensure t
  :straight t
  :after lsp-mode
  :config
  (setq lsp-java-java-path (or (executable-find "java")
                               lsp-java-java-path)))

;; Lean4
(use-package lean4-mode
  :ensure t
  :straight (lean4-mode :type git :host github
                        :repo "leanprover-community/lean4-mode"
                        :files ("*.el" "data"))
  :commands lean4-mode)

;; Auto-match parentheses
(use-package smartparens
  :ensure t
  :straight t
  :hook (prog-mode text-mode markdown-mode ciao-mode ciao-inferior-mode)
  :config (require 'smartparens-config))

;; Snippets
(use-package yasnippet
  :ensure t
  :straight t
  :functions (yas-reload-all)
  :config
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  (yas-reload-all)
  :hook
  ((prog-mode . yas-minor-mode-on)
   (text-mode . yas-minor-mode-on)
   (ciao-mode . yas-minor-mode-on)
   (ciao-inferior-mode . yas-minor-mode-on)))

;; Markdown
(use-package markdown-mode
  :defer t
  :straight t
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

;; PDF-tools
(use-package pdf-tools
  :ensure t
  :straight t
  :mode ("\\.[pP][dD][fF]\\'" . pdf-view-mode)
  :magic ("%PDF" . pdf-view-mode)
  :custom (pdf-view-display-size 'fit-width)
  :bind (:map pdf-view-mode-map
              ("C-s"     . isearch-forward)
              ("C-c C-f" . my/slides-presentation))
  :hook (pdf-view-mode . (lambda ()
                           (set (make-local-variable 'evil-emacs-state-cursor) (list nil))
                           (display-line-numbers-mode -1)
                           (setq-local pdf-view-use-scaling t))))

;; Install/load PDF-tools
(require 'pdf-tools)
(pdf-tools-install)

;; AUCTeX
(use-package auctex
  :defer t
  :ensure t
  :straight t
  :functions (LaTeX-fill-paragraph
              TeX-revert-document-buffer)
  :defines (TeX-auto-save
            TeX-parse-self
            TeX-show-compilation
            TeX-global-PDF-mode
            TeX-clean-confirm
            TeX-command-default
            TeX-view-program-selection
            TeX-source-correlate-mode
            TeX-source-correlate-method
            TeX-source-correlate-start-server)
  :hook
  (LaTeX-mode . (lambda ()
                  (pdf-tools-install) ;; TODO: Redundant?
			      (outline-minor-mode 1)
				  (display-line-numbers-mode 1)
				  (add-hook 'pdf-view-mode-hook
			   			    (lambda () (display-line-numbers-mode -1))
						    :append :local)

       	          (setq fill-column 70)
                  (setq TeX-auto-save t
                        TeX-parse-self t
                        TeX-show-compilation nil
                        TeX-global-PDF-mode t
                        TeX-clean-confirm nil
                        TeX-command-default "LaTeX"
                        TeX-view-program-selection '((output-pdf "PDF Tools"))
                        TeX-source-correlate-mode t
                        TeX-source-correlate-method '((dvi . source-specials)
                                                      (pdf . synctex))
                        TeX-source-correlate-start-server t)

                  (local-set-key (kbd "M-q") #'LaTeX-fill-paragraph))))

(add-hook 'TeX-after-compilation-finished-functions
          #'TeX-revert-document-buffer)

;; Provide ourselves
(provide 'languages-config)

;;; `languages-config.el' ends here
