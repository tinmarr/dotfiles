;; Setup Package Manager
(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

;; Initialize use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Add diminish
(use-package diminish)

(use-package evil
  :diminish
  :custom
  (evil-undo-system 'undo-redo)
  (evil-want-C-d-scroll t)
  (evil-want-C-u-scroll t)
  (evil-search-module 'swiper)
  (evil-auto-indent nil)
  (evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection 
  :diminish evil-collection-unimpaired-mode
  :after evil
  :config
  (evil-collection-init))

(use-package general
  :after evil
  :config
  ; Better vim motions
  (general-define-key :states '(normal visual) "C-u" (general-simulate-key ('evil-scroll-up "z z")))
  (general-define-key :states '(normal visual) "C-d" (general-simulate-key ('evil-scroll-down "z z")))
  ; Prefixes
  (general-create-definer leader
    :states '(normal visual)
    :prefix "SPC")
  ; Bindings
  (leader org-mode-map "i" 'org-edit-latex-fragment)
  (general-define-key :states 'normal "C-o" 'find-file)
  (leader :states 'normal "RET" 'dashboard-open)
  (general-define-key :states 'normal "C-e" 'neotree-toggle)
  (general-define-key :states 'normal "C-i" 'lsp-ui-imenu)
  ; Projectile
  (general-define-key :states 'normal "C-p" 'projectile-find-file)
  (general-define-key :states 'normal "C-S-o" 'projectile-switch-project)
  (general-define-key :states 'normal "C-S-f" 'projectile-ripgrep)
  ; Buffer management
  (leader "b l" 'list-buffers)
  (leader "b i" 'switch-to-buffer)
  (leader "b j" 'next-buffer)
  (leader "b k" 'previous-buffer)
  (leader "b h" 'kill-current-buffer)
)

(global-set-key [escape] 'keyboard-escape-quit)

(use-package which-key
  :config
  (which-key-mode)
  (which-key-add-key-based-replacements "SPC b" "Buffer Management")
)

(set-locale-environment "en_US.UTF-8")
(set-language-environment "English")
(setenv "LANG" "en_US.UTF-8")

(use-package dracula-theme
  :config
  (load-theme 'dracula t)
)

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-hud t)
  (doom-modeline-modal-modern-icon nil)
)

(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font Mono" :height 110)

(use-package ligature
  :config
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://"))
  (global-ligature-mode 't)
)

(use-package nerd-icons
  :custom 
  (nerd-icons-font-family "JetBrainsMono Nerd Font Mono")
 )

(use-package all-the-icons)

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)

(menu-bar-mode -1)

;; Line numbers
(column-number-mode)
(setq-default display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

;; Disable dialogs/popup windows'
(setq use-file-dialog nil)   ;; No file dialog
(setq use-dialog-box nil)    ;; No dialog box
(setq pop-up-windows nil)    ;; No popup windows

(set-frame-parameter nil 'alpha-background 80)

(add-to-list 'default-frame-alist '(alpha-background . 80))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :diminish
  :hook org-mode prog-mode)

(diminish 'eldoc-mode)

(use-package projectile
  :diminish
  :custom
  (projectile-git-command "git ls-files -zco") 
  :config
  (projectile-mode 1))

(use-package ripgrep)

(use-package dashboard
  :requires (nerd-icons projectile)
  :custom
  (dashboard-banner-logo-title "Hello Martin. Welcome to Emacs")
  (dashboard-startup-banner 'logo)
  (dashboard-center-content t)
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons) 
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-items '((projects . 5)
                     (bookmarks . 5)
                     (recents  . 10)))
  :config
  (dashboard-setup-startup-hook))

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

(use-package org
  :diminish org-indent-mode
  :custom
  (org-hide-emphasis-markers t)
  (org-startup-indented t)
  (org-startup-with-latex-preview t)
  (org-startup-with-inline-images t)
  (org-image-actual-width '(0.5))
  (org-edit-src-content-indentation 0)
)

(use-package org-superstar
  :hook (org-mode . (lambda () (org-superstar-mode 1)))
  :config
  (setq org-superstar-leading-bullet "  ")
  (setq org-superstar-special-todo-items t))

(setq org-format-latex-options 
  '(:foreground default 
    :background default 
    :scale 3
    :html-foreground "Black" 
    :html-background "Transparent" 
    :html-scale 1.0 
    :matchers ("begin" "$1" "$" "$$" "\\(" "\\[")))
(add-hook 'org-mode-hook
  (lambda ()
      (add-hook 'after-save-hook 'org-latex-preview nil 'make-local)))

(add-hook 'org-mode-hook
  (lambda ()
      (add-hook 'after-save-hook (lambda () (org-display-inline-images)))))

(add-hook 'org-mode-hook
    (lambda ()
        (add-hook 'after-save-hook #'org-babel-tangle
                nil 'make-it-local)))

(use-package neotree
  :custom
  (neo-theme 'icons 'arrow)
)

(setq treesit-language-source-alist
  '((bash "https://github.com/tree-sitter/tree-sitter-bash")
    (python "https://github.com/tree-sitter/tree-sitter-python")
   ))

(add-hook 'sh-mode-hook 'bash-ts-mode)
(add-hook 'python-mode-hook 'python-ts-mode)

(use-package markdown-mode)

(use-package lsp-mode
  :hook (python-ts-mode . lsp)
  :commands lsp
)
(use-package lsp-ui)

(use-package lsp-pyright
  :init
  (setq lsp-pyright-multi-root nil)
)

(use-package ivy
:diminish
:bind (:map ivy-minibuffer-map
        ("C-l" . ivy-alt-done)
        ("TAB" . ivy-alt-done)
        ("C-j" . ivy-next-line)
        ("C-k" . ivy-previous-line))
:config
(setq ivy-switch-buffer-map nil) ; Remove default kill buffer binding
(ivy-mode 1))

(use-package swiper)

(setq backup-directory-alist '(("." . "~/.config/emacs/backup"))
      backup-by-copying      t  ; Don't de-link hard links
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups:
      kept-new-versions      20 ; how many of the newest versions to keep
      kept-old-versions      2) ; and how many of the old

(setq custom-file "~/.config/emacs/emacs-custom.el")
(load custom-file)

(add-hook 'prog-mode-hook 'hs-minor-mode)

(global-auto-revert-mode)

(use-package flycheck
  :config
  (flycheck-mode)
)

(use-package company
  :config
  (company-mode)
)
