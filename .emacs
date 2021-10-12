;; NOTE: .emacs is now generated from Emacs.org.  Please edit that file
;;       in Emacs and .emacs will be generated automatically!

;; You will most likely need to adjust this font size for your system!
(defvar mitchymitch/default-font-size 180)
(defvar mitchymitch/default-variable-font-size 180)

(setq system-uses-terminfo nil)
;; start up in full screen
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Initialize package sources
(require 'package)

;; Set package repos
(setq package-archives '(("melpa" . "https://stable.melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell nil)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		shell-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package general
  :config
  (general-create-definer rune/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (rune/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
    "o" '(:ignore t :which-key "org")
    "oa" '(org-agenda :which-key "org-agenda")
    "oc" '(org-capture :which-key "org-capture")))

;; these are in Transient settings
;;(rune/leader-keys
;;  "ts" '(hydra-text-scale/body :which-key "scale text"))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; lol not a doom theme
(use-package doom-themes
  :init (load-theme 'doom-gruvbox t))
;; I like misterioso

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 10)))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-immediate-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
     ("C-x b" . counsel-ibuffer)
     ("C-x C-f" . counsel-find-file)
     ("C-M-j" . 'counsel-switch-buffer)
     :map minibuffer-local-map
     ("C-r" . 'counsel-minibuffer-history))
  :config
  (counsel-mode 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(rune/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))

;; (use-package treemacs)
;; (use-package treemacs-evil)
;; (use-package treemacs-projectile)

;; setting org keybindings
(global-set-key (kbd "C-c l") 'org-store-link)

(setq org-directory "~/org")
(setq org-default-notes-file (concat org-directory "/gtd/inbox.org"))
(defun mitchymitch/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :hook (org-mode . mitchymitch/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawler t)


  (setq org-refile-targets
        '(("~/org/Archive.org" :maxlevel . 1)
          ("~/org/gtd/projects.org" :maxlevel . 2))))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
        (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  ;; Default tags in view

  (setq org-tag-alist
        '((:startgroup)
                                        ; Put mutually exclusive tags here
          (:endgroup)
          ("errand" . ?E)
          ("home" . ?H)
          ("3l" . ?A)
          ("staples" . ?s)
          ("planning" . ?p)
          ("note" . ?n)
          ("idea" . ?i)))

(global-set-key (kbd "C-c c") 'org-capture)
(setq org-capture-templates
        `(("t" "Tasks / Projects")
            ("tt" "Task" entry (file+olp "~/org/gtd/inbox.org" "Inbox")
            "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

            ("j" "Journal Entries")
            ("jj" "Journal" entry

            (file+olp+datetree "~/org/journal.org" "Journal")
            "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
            ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
            :clock-in :clock-resume
            :empty-lines 1)
            ("jm" "Meeting" entry
            (file+olp+datetree "~/org/work/journal.org" "Meetings")
            "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
            :clock-in :clock-resume
            :empty-lines 1)
            ("jw" "Work Journal" entry
            (file+olp+datetree "~/org/work/journal.org" "Journal")
            "* %<I:%M %p> - %a :journal:\n\n%?\n\n"
            :clock-in :clock-resume
            :empty-lines 1)))

    (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

(global-set-key (kbd "C-c a") 'org-agenda)

(setq org-agenda-files
       '((concat org-directory "/gtd/inbox.org")
       (concat org-directory "/gtd/projects.org")))
 ;; Configure custom agenda views
(setq org-agenda-custom-commands
       ;; (key descr (type) match settings file)
       '(("d" "Dashboard"
	  ;; type: 
	  ((agenda "" ((org-deadline-warning-days 7)))
	   (todo "NEXT"
		 ((org-agenda-overriding-header "Next Tasks")))
	   (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

	 ("n" "Next Tasks"
	  ((todo "NEXT"
		 ((org-agenda-overriding-header "Next Tasks")))))

	 ("W" "Work Tasks" tags-todo "+staples")

	 ;; Low-effort next actions
	 ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
	  ((org-agenda-overriding-header "Low Effort Tasks")
	   (org-agenda-max-todos 20)
	   (org-agenda-files org-agenda-files)))

	 ("w" "Workflow Status"
	  ((todo "WAIT"
		 ((org-agenda-overriding-header "Waiting on External")
		  (org-agenda-files org-agenda-files)))
	   (todo "REVIEW"
		 ((org-agenda-overriding-header "In Review")
		  (org-agenda-files org-agenda-files)))
	   (todo "PLAN"
		 ((org-agenda-overriding-header "In Planning")
		  (org-agenda-todo-list-sublevels nil)
		  (org-agenda-files org-agenda-files)))
	   (todo "BACKLOG"
		 ((org-agenda-overriding-header "Project Backlog")
		  (org-agenda-todo-list-sublevels nil)
		  (org-agenda-files org-agenda-files)))
	   (todo "READY"
		 ((org-agenda-overriding-header "Ready for Work")
		  (org-agenda-files org-agenda-files)))
	   (todo "ACTIVE"
		 ((org-agenda-overriding-header "Active Projects")
		  (org-agenda-files org-agenda-files)))
	   (todo "COMPLETED"
		 ((org-agenda-overriding-header "Completed Projects")
		  (org-agenda-files org-agenda-files)))
	   (todo "CANC"
		 ((org-agenda-overriding-header "Cancelled Projects")
		  (org-agenda-files org-agenda-files)))))))

(require 'org-habit)
(add-to-list 'org-modules 'org-habit)
(setq org-habit-graph-column 60)

(require 'org-faces)

(defun mitchymitch/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  (dolist (face '((org-level-1 . 1.2)
              (org-level-2 . 1.1)
              (org-level-3 . 1.05)
              (org-level-4 . 1.0)
              (org-level-5 . 1.1)
              (org-level-6 . 1.1)
              (org-level-7 . 1.1)
              (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))


  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

  (mitchymitch/org-font-setup)

(require 'org-bullets)
(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun mitchymitch/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . mitchymitch/org-mode-visual-fill))

(org-babel-do-load-languages
  'org-babel-load-languages
  '((emacs-lisp . t)
    (python . t)))

(push '("conf-unix" . conf-unix) org-src-lang-modes)

;; This is needed as of Org 9.2
(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))
(add-to-list 'org-structure-template-alist '("sql" . "src sql"))

;; Automatically tangle our Emacs.org config file when we save it
(defun mitchymitch/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.config/Emacs.org"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'mitchymitch/org-babel-tangle-config)))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; not sure why this package can't be found?
;; (use-package evil-magit
;;  :after magit)

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
;;(use-package forge)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package exec-path-from-shell :ensure t)
(exec-path-from-shell-initialize)

(use-package lsp-mode
    :init
    (setq lsp-prefer-flymake nil)
    :demand t
    :after jmi-init-platform-paths
    :config (add-hook 'java-mode-hook 'lsp))

(use-package lsp-ui
  :config
  (setq lsp-ui-doc-enable nil
        lsp-ui-sideline-enable nil
        lsp-ui-flycheck-enable t)
  :after lsp-mode)

(use-package dap-mode
  :config
  (dap-mode t)
  (dap-ui-mode t))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)

(use-package lsp-java
  :init
  (defun jmi/java-mode-config ()
    (setq-local tab-width 4
                c-basic-offset 4)
    (toggle-truncate-lines 1)
    (setq-local tab-width 4)
    (setq-local c-basic-offset 4)
    (lsp))

  :config
  ;; Enable dap-java
  (require 'dap-java)

  ;; Support Lombok in our projects, among other things
  (setq lsp-java-vmargs
        (list "-noverify"
              "-Xmx2G"
              "-XX:+UseG1GC"
              "-XX:+UseStringDeduplication"
              (concat "-javaagent:" jmi/lombok-jar)
              (concat "-Xbootclasspath/a:" jmi/lombok-jar))
        lsp-file-watch-ignored
        '(".idea" ".ensime_cache" ".eunit" "node_modules"
          ".git" ".hg" ".fslckout" "_FOSSIL_"
          ".bzr" "_darcs" ".tox" ".svn" ".stack-work"
          "build")

        lsp-java-import-order '["" "java" "javax" "#"]
        ;; Don't organize imports on save
        lsp-java-save-action-organize-imports nil

        ;; Formatter profile
        lsp-java-format-settings-url
        (concat "file://" jmi/java-format-settings-file))

  :hook (java-mode   . jmi/java-mode-config)

  :demand t
  :after (lsp lsp-mode dap-mode jmi-init-platform-paths))

(add-hook 'go-mode-hook #'lsp-deferred)

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(use-package dired
    :ensure nil
    :commands (dired dired-jump)
    :bind (("C-x C-j" . dired-jump))
    :custom ((dired-listing-switches "-agho "))
  ;; --group-directories-first doesn't work on mac
    :config
    (evil-collection-define-key 'normal 'dired-mode-map
      "h" 'dired-single-up-directory
      "l" 'dired-single-buffer))

  (use-package dired-single)

  (use-package all-the-icons-dired
    :hook (dired-mode . all-the-icons-dired-mode))

;;  (use-package dired-open
;;    :config
;;    ;; Doesn't work as expected!
;;    ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
;;    (setq dired-open-extensions '(("png" . "feh")
;;                                  ("mkv" . "mpv"))))
;;
;;  (use-package dired-hide-dotfiles
;;    :hook (dired-mode . dired-hide-dotfiles-mode)
;;    :config
;;    (evil-collection-define-key 'normal 'dired-mode-map
;;      "H" 'dired-hide-dotfiles-mode))
