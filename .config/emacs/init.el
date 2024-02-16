;; Setup Package Manager
(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package evil
  :init
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-C-d-scroll t)
  (setq evil-want-C-u-scroll t)
  (setq evil-search-module 'swiper)
  (setq evil-auto-indent nil)
  :config
  (evil-mode 1))

(use-package general
  :after evil
  :config
  (general-create-definer spc-def
    :states 'normal
    :prefix "SPC")
  (spc-def org-mode-map "i" 'org-edit-latex-fragment)
  (general-define-key :states '(normal insert) "C-p" 'find-file)
)

(use-package dracula-theme
  :config
  (load-theme 'dracula t))

(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font Mono" :height 110)

(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)

(menu-bar-mode -1)

;; Line numbers
(column-number-mode)
(setq-default display-line-numbers 'relative)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package org
  :config
  (setq org-hide-emphasis-markers t)
  (setq org-startup-indented t))
  (setq org-startup-with-latex-preview t)

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

(use-package ivy
:bind (:map ivy-minibuffer-map
        ("C-l" . ivy-alt-done)
        ("TAB" . ivy-alt-done)
        ("C-j" . ivy-next-line)
        ("C-k" . ivy-previous-line))
:config
(ivy-mode 1))

(use-package swiper)

(add-hook 'org-mode-hook
    (lambda ()
        (add-hook 'after-save-hook #'org-babel-tangle
                nil 'make-it-local)))

(when (fboundp 'electric-indent-mode) (electric-indent-mode -1))

(setq backup-directory-alist '(("." . "~/.config/emacs/backup"))
      backup-by-copying      t  ; Don't de-link hard links
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups:
      kept-new-versions      20 ; how many of the newest versions to keep
      kept-old-versions      2) ; and how many of the old
