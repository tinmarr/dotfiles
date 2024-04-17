(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                 ,@(when-let ((depth (plist-get order :depth)))
                                                     (list (format "--depth=%d" depth) "--no-single-branch"))
                                                 ,(plist-get order :repo) ,repo))))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;; Block until current queue processed.
(elpaca-wait)

(use-package evil
  :ensure t
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
  :ensure t
  :after evil
  :config
  (evil-collection-init))

(use-package general
  :ensure t
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
  (general-define-key :states 'normal "C-e" 'treemacs-select-window)
  (general-define-key :states 'normal "C-i" 'lsp-ui-imenu)
  ; Projectile
  (general-define-key :states 'normal "C-p" 'projectile-find-file)
  (general-define-key :states 'normal "C-S-o" 'projectile-switch-project)
  (general-define-key :states 'normal "C-S-f" 'projectile-ripgrep)
  ; Buffer management
  (leader "b l" 'ibuffer)
  (leader "b i" 'switch-to-buffer)
  (leader "b j" 'next-buffer)
  (leader "b k" 'previous-buffer)
  (leader "b h" 'kill-current-buffer)
  ; LSP binding
  (leader "l d" 'lsp-find-definition)
  (leader "l f" 'lsp-find-references)
  (leader "l r" 'lsp-rename)
  (leader "l R" 'lsp-workspace-restart)
)

(global-set-key [escape] 'keyboard-escape-quit)

(use-package which-key
  :ensure t
  :config
  (which-key-mode)
  (which-key-add-key-based-replacements "SPC b" "Buffer Management")
  (which-key-add-key-based-replacements "SPC l" "LSP hotkeys")
)

(set-locale-environment "en_US.UTF-8")
(set-language-environment "English")
(setenv "LANG" "en_US.UTF-8")

(use-package dracula-theme
  :ensure t
  :config
  (load-theme 'dracula t)
)

(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-hud t)
  (doom-modeline-modal-modern-icon nil)
)

(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font-11"))
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font-11")

(use-package ligature
  :ensure t
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
  :ensure t
  :custom 
  (nerd-icons-font-family "JetBrainsMono Nerd Font Mono")
 )

(use-package all-the-icons :ensure t)

(use-package all-the-icons-dired
  :ensure t
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

;; remove line wrap
(setq-default truncate-lines t)
;(toggle-truncate-lines 1)

(set-frame-parameter nil 'alpha-background 90)

(add-to-list 'default-frame-alist '(alpha-background . 90))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :ensure t
  :hook org-mode prog-mode)

;(diminish 'eldoc-mode)

(use-package projectile
  :ensure t
  :config
  (projectile-mode 1))

(use-package ripgrep :ensure t)

(use-package dashboard
  :ensure t
  :requires (nerd-icons projectile)
  :custom
  (dashboard-banner-logo-title "Hello Martin. Welcome to Emacs")
  (dashboard-startup-banner "~/.config/emacs/logo.webp")
  (dashboard-image-banner-max-height 250)
  (dashboard-center-content t)
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons) 
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-projects-backend 'projectile)
  (dashboard-items '((projects . 10)
                     (recents  . 10)))
  :config
  (dashboard-setup-startup-hook))

(setq initial-buffer-choice (lambda () (get-buffer-create dashboard-buffer-name)))

(use-package org
  :ensure t
  :custom
  (org-hide-emphasis-markers t)
  (org-startup-indented t)
  (org-startup-with-latex-preview t)
  (org-startup-with-inline-images t)
  (org-image-actual-width '(0.5))
  (org-edit-src-content-indentation 0)
  (org-hide-leading-stars t)
)

(use-package org-superstar
  :ensure t
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

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(require 'treesit)
(customize-set-variable 'treesit-font-lock-level 4)

(setq major-mode-remap-alist
 '((sh-mode . bash-ts-mode)
   (js-mode . js-ts-mode)
   (js-json-mode . json-ts-mode)
   (css-mode . css-ts-mode)
   (python-mode . python-ts-mode)
  )
)

(use-package markdown-mode :ensure t)

(use-package lsp-mode
  :ensure t
  :hook (
    (css-ts-mode . lsp)
  )
  :commands lsp
)
(use-package lsp-ui :ensure t)

(use-package web-mode
  :ensure t
  :hook (
    (html-mode . web-mode)
    (mhtml-mode . web-mode)
    (web-mode . lsp)
  )
)

(use-package lsp-pyright
  :ensure t
  :hook
  (python-ts-mode . (lambda () (lsp) ));(flycheck-add-next-checker 'lsp 'python-pylint)))
  :init
  (setq lsp-pyright-multi-root nil)
)

(use-package lsp-java
  :ensure t
  :hook (java-ts-mode . lsp)
)

(use-package ivy
  :ensure t
  :bind (:map ivy-minibuffer-map
          ("C-l" . ivy-alt-done)
          ("TAB" . ivy-alt-done)
          ("C-j" . ivy-next-line)
          ("C-k" . ivy-previous-line))
  :config
  (setq ivy-switch-buffer-map nil) ; Remove default kill buffer binding
  (ivy-mode 1))

(use-package swiper :ensure t)

(setq backup-directory-alist '(("." . "~/.config/emacs/backup"))
      backup-by-copying      t  ; Don't de-link hard links
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups:
      kept-new-versions      20 ; how many of the newest versions to keep
      kept-old-versions      2) ; and how many of the old

(setq custom-file "~/.config/emacs/emacs-custom.el")
(ignore-errors (load custom-file))

(add-hook 'prog-mode-hook 'hs-minor-mode)

(global-auto-revert-mode)

(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode)
)

(use-package company
  :ensure t
  :config
  (company-mode)
)
