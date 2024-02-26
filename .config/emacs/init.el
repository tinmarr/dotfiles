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
  ; Prefixes
  (general-create-definer spc-def
    :states 'normal
    :prefix "SPC")
  ; Bindings
  (spc-def org-mode-map "i" 'org-edit-latex-fragment)
  (general-define-key :states 'normal "C-o" 'find-file)
  (general-define-key :states 'normal "M-RET" 'dashboard-open)
  (general-define-key :states 'normal "C-e" 'neotree-toggle)
  ; Projectile
  (general-define-key :states 'normal "C-p" 'projectile-find-file)
  (general-define-key :states 'normal "C-S-O" 'projectile-switch-project)
  (general-define-key :states 'normal "C-S-F" 'projectile-grep)
)

(global-set-key [escape] 'keyboard-escape-quit)

(use-package dracula-theme
  :diminish
  :config
  (load-theme 'dracula t))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-hud t)
  (doom-modeline-modal-modern-icon nil)
)

(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font Mono" :height 110)

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

(set-frame-parameter nil 'alpha-background 95)

(add-to-list 'default-frame-alist '(alpha-background . 95))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :diminish
  :hook org-mode prog-mode)

(diminish 'eldoc-mode)

(use-package projectile
  :diminish
  :config
  (projectile-mode 1))

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
      (add-hook 'after-save-hook (lambda () (org-latex-preview)))))

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

(use-package pdf-tools
  :init (pdf-loader-install)
)

(add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))

(use-package markdown-mode)

(use-package ivy
:diminish
:bind (:map ivy-minibuffer-map
        ("C-l" . ivy-alt-done)
        ("TAB" . ivy-alt-done)
        ("C-j" . ivy-next-line)
        ("C-k" . ivy-previous-line))
:config
(ivy-mode 1))

(use-package swiper)

(electric-indent-mode -1) ; Disable auto indenting
(electric-pair-mode 1) ; Enable auto paren pairing

(setq backup-directory-alist '(("." . "~/.config/emacs/backup"))
      backup-by-copying      t  ; Don't de-link hard links
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups:
      kept-new-versions      20 ; how many of the newest versions to keep
      kept-old-versions      2) ; and how many of the old
