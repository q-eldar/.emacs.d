;;;;;;;;;; USE-PACKAGE ;;;;;;;;;;
;; https://github.com/jwiegley/use-package
;; https://github.com/cocreature/dotfiles/blob/master/emacs/.emacs.d/emacs.org
;; https://github.com/mguinada/emacs.d/blob/master/init.el
;; https://github.com/psibi/dotfiles/blob/master/.emacs.d/init.el
;;;;;;;;;; .EMACS.D ;;;;;;;;;;;;;
;; https://github.com/jbranso/.emacs.d

;; https://explog.in/dot/emacs/config.html
;; http://tech.memoryimprintstudio.com/pdf-annotation-related-tools/
(setq warning-suppress-log-types '((package reinitialization)))
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-linum-mode -1) ;; disable line numbers globally
(pending-delete-mode t)

(setq inhibit-startup-screen t)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq inhibit-startup-message t)
;; (setq-default tab-width 2)
;; (setq-default indent-tabs-mode nil)
(fset 'yes-or-no-p 'y-or-n-p)

(global-set-key "\M-p" 'backward-paragraph)
(global-set-key "\M-n" 'forward-paragraph)

;; move line up
(defun move-line-up ()
  (interactive)
  (transpose-lines 1)
  (previous-line 2))
;; move line down
(defun move-line-down ()
  (interactive)
  (next-line 1)
  (transpose-lines 1)
  (previous-line 1))

(global-set-key [(control shift t)] 'move-line-up)
(global-set-key [(meta shift t)] 'move-line-down)

(display-time-mode 1)

(require 'cask "~/.cask/cask.el")
(cask-initialize)
;; (package-initialize)
;; (package-initialize nil)
;; (add-to-list 'package-archives
;;              '("org" . "http://orgmode.org/elpa/"))
;; (add-to-list 'package-archives
;;              '("melpa" . "http://melpa.org/packages/") t)
;; (setq package-archive-priorities '(("org" . 3)
;;                                    ("melpa" . 2)
;;                                    ("gnu" . 1)))
;;;;------>  https://jwiegley.github.io/use-package/keywords/#after
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(setq use-package-verbose t)
(eval-when-compile
  (require 'use-package))

(use-package multiple-cursors
  :ensure t
  :init
  :bind(("C->" . mc/mark-next-like-this)
	("C-<" . mc/mark-previous-like-this)
	("C-c C-<" . mc/mark-all-like-this))
  )
;; save cursor position for a file
(use-package saveplace
  :ensure t
  :init (save-place-mode)
  :config
  (setq save-place-file (concat user-emacs-directory "saveplace.el"))
  (setq-default save-place t)
  :defer t
  )

(require 'saveplace-pdf-view)
;; (use-package projectile
;;   :diminish projectile-mode
;;   :config (projectile-mode)
;;   :bind-keymap
;;   ("C-c p" . projectile-command-map)
;;   :init
;;   (when (file-directory-p "~/js/my-app")
;;     (setq projectile-project-search-path '("~/js/my-app")))
;;   (setq projectile-switch-project-action #'projectile-dired)
;;   )

(use-package major-mode-hydra
  :ensure t
  :demand t
  :bind
  ("M-SPC" . major-mode-hydra))
(use-package diminish)
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ORG;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                            ;;

(use-package org
  :ensure nil
  :mode ("\\.org\\'" . org-mode)
  :bind (("C-c l" . org-store-link)
         ("C-c c" . org-capture)
         ("C-c a" . org-agenda)
         ("C-c b" . org-iswitchb)
         ("C-c C-w" . org-refile)
         ("C-c j" . org-clock-goto)
         ("C-c C-x C-o" . org-clock-out)
         :map org-mode-map
         ("<" . (lambda ()
                  "Insert org template."
                  (interactive)
                  (if (or (region-active-p) (looking-back "^\s*" 1))
                      (org-hydra/body)
                    (self-insert-command 1)))))
  :commands (org-dynamic-block-define)
  :custom-face (org-ellipsis ((t (:foreground nil))))
  :pretty-hydra
  ((:color blue :quit-key "q" :title "Org Template")
   ("Basic"
    ( ("c" (hot-expand "<c") "center")
      ("E" (hot-expand "<E") "export")
     ("h" (hot-expand "<h") "html")
     ("l" (hot-expand "<l") "latex")
     ("n" (hot-expand "<n") "note")
     ("o" (hot-expand "<q") "quote")
     )
    "Head"
    (("i" (hot-expand "<i") "index")
     ("A" (hot-expand "<A") "ASCII")
     ("I" (hot-expand "<I") "INCLUDE")
     ("H" (hot-expand "<H") "HTML")
     ("L" (hot-expand "<L") "LaTeX"))
    "Source"
    (("S" (hot-expand "<s") "src")
     ("m" (hot-expand "<s" "emacs-lisp") "emacs-lisp")
     ("p" (hot-expand "<s" "python :results output") "python")
     ("s" (hot-expand "<s" "shell") "shell")
     ))
   )
  :hook (((org-babel-after-execute org-mode) . org-redisplay-inline-images) ; display image
         (org-mode . (lambda ()
                       "Beautify org symbols."
                       (setq prettify-symbols-alist centaur-prettify-org-symbols-alist)
                       (prettify-symbols-mode 1)))
         (org-indent-mode . (lambda()
                              (diminish 'org-indent-mode)
                              ;; WORKAROUND: Prevent text moving around while using brackets
                              ;; @see https://github.com/seagle0128/.emacs.d/issues/88
                              (make-variable-buffer-local 'show-paren-mode)
                              (setq show-paren-mode nil))))
  :config
  ;; (setq org-startup-indented nil)
  ;; https://github.com/seagle0128/.emacs.d/blob/master/lisp/init-org.el
  (defun hot-expand (str &optional mod)
    "Expand org template.
STR is a structure template string recognised by org like <s. MOD is a
string with additional parameters to add the begin line of the
structure element. HEADER string includes more parameters that are
prepended to the element after the #+HEADER: tag."
    (let (text)
      (when (region-active-p)
        (setq text (buffer-substring (region-beginning) (region-end)))
        (delete-region (region-beginning) (region-end)))
      (insert str)
      (if (fboundp 'org-try-structure-completion)
          (org-try-structure-completion) ; < org 9
        (progn
          ;; New template expansion since org 9
          (require 'org-tempo nil t)
          (org-tempo-complete-tag)))
      (when mod (insert mod) (forward-line))
      (when text (insert text))))
  ;; Babel
  (setq org-confirm-babel-evaluate nil
        org-src-fontify-natively t
        org-src-tab-acts-natively t)

  (defvar load-language-list '((emacs-lisp . t)
                               (python . t)
			       (C . t)
			       (shell . t)))

  (org-babel-do-load-languages 'org-babel-load-languages
                               load-language-list)
  
  (setq org-src-window-setup 'current-window)
  (setq org-src-preserve-indentation t)
  (setq org-time-clocksum-format '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))
  (setq org-startup-folded t)
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))
  (setq org-catch-invisible-edits 'smart))

(use-package org-inlinetask
  :bind (:map org-mode-map
              ("C-c C-x t" . org-inlinetask-insert-task))
  :after (org)
  :commands (org-inlinetask-insert-task))
(use-package org-bullets
  :ensure t
  :commands (org-bullets-mode)
  :custom
  ;; https://zhangda.wordpress.com/2016/02/15/configurations-for-beautifying-emacs-org-mode/
  (org-bullets-bullet-list '("⁖" "☯" "○" "☯" "✸" "☯" "✿" "☯" "✜" "☯" "◆" "☯" "▶"))
  (org-ellipsis "⤵")
  :init (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))
  
;; end org

(use-package doom-themes
  :ensure t
  :preface (defvar region-fg nil)
  :config (load-theme 'doom-one t))

(use-package yasnippet
  :ensure t
  :bind
  ("C-c y s" . yas-insert-snippet)
  :config
  (yas-global-mode)
  )
;; https://cloudnine.github.io/science/2020-08-08-emacs-emmet-mode-yasnippet/
(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :bind
  ("C-c y s" . yas-insert-snippet)
  :config
  (use-package yasnippet-snippets)
  (yas-global-mode 1)
  )
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;LSP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                            ;;

(use-package lsp-mode
  :ensure t
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (cpp-mode . lsp)
	 (lisp-mode . lsp)
	 (cpp-mode . lsp-deferred)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-deferred))

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
(use-package lsp-ui
  :ensure t
  :config
  (define-key lsp-ui-mode-map (kbd "M-.") 'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  :commands lsp-ui-mode)

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (yas-global-mode)
  )
(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
    (which-key-mode))
(require 'lsp-mode)
(lsp-register-client
    (make-lsp-client :new-connection (lsp-tramp-connection "clangd")
                     :major-modes '(c-mode)
                     :remote? t
                     :server-id 'clangd-remote))

;; sample `helm' configuration use https://github.com/emacs-helm/helm/ for details
;; (helm-mode)
;; (require 'helm-xref)
;; (define-key global-map [remap find-file] #'helm-find-files)
;; (define-key global-map [remap execute-extended-command] #'helm-M-x)
;; (define-key global-map [remap switch-to-buffer] #'helm-mini)
;; (use-package helm-lsp :commands helm-lsp-workspace-symbol)


;; (require' lsp-ui)

;; https://emacs-lsp.github.io/lsp-mode/tutorials/how-to-turn-off/
(setq lsp-ui-doc-enable nil)

;; (setq lsp-disabled-clients '(eslint))
;; python-lsp :: https://www.mattduck.com/lsp-python-getting-started.html
;; (add-hook 'python-mode-hook 'eglot-ensure)
(use-package lsp-python-ms
  :ensure t
  :init (setq lsp-python-ms-auto-install-server t)
  :hook (python-mode . (lambda ()
                          (require 'lsp-python-ms)
                          (lsp-deferred))))  ; or lsp-deferred
(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window))
(use-package avy
  :ensure avy
  :bind (("C-;" . avy-goto-char)
         ;; ("C-ö" . avy-goto-word-1)
         ("C-:" . avy-goto-char-2)
         ;; ("C-ü" . avy-goto-line)
	 )
  :config (setq avy-case-fold-search nil))

;; (setq ivy-count-format "(%d/%d) ")
;; (setq enable-recursive-minibuffers t)
;; enable this if you want `swiper' to use it
;; (setq search-default-mode #'char-fold-to-regexp)
(use-package ivy
  :ensure t)
(use-package swiper
  :ensure t
  :diminish ivy-mode
  :bind (("C-r" . swiper)
         ("C-c C-r" . ivy-resume)
         ("C-c h m" . woman)
         ;; ("C-x b" . ivy-switch-buffer)
         ("C-c u" . swiper-all)
	 ("C-s" . swiper-isearch)
	 )
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t))
(use-package counsel
  :ensure t
  :commands (counsel-mode)
  :bind
  (("M-y" . counsel-yank-pop)
   :map ivy-minibuffer-map
   ("M-y" . ivy-next-line))
  ;; ("C-h v" . counsel-describe-variable)
  ;; ("C-h f" . counsel-describe-function)
  )

;; (use-package counsel-projectile
;;   :config (counsel-projectile-mode)
;;   )

;; (global-set-key (kbd "M-x") 'counsel-M-x)
;; (global-set-key (kbd "C-x C-f") 'counsel-find-file)


;; (global-set-key (kbd "<f1> l") 'counsel-find-library)
;; (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
;; (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
;; (global-set-key (kbd "<f2> j") 'counsel-set-variable)
;; (global-set-key (kbd "C-x b") 'ivy-switch-buffer)
;; (global-set-key (kbd "C-c v") 'ivy-push-view)
;; (global-set-key (kbd "C-c V") 'ivy-pop-view)

;; https://github.com/nonsequitur/smex
(use-package smex
  :ensure t
  :bind ("M-x" . smex))

;; (global-set-key (kbd "M-X") 'smex-major-mode-commands)
(use-package ibuffer-projectile
  :defer t
  :init
  (add-hook 'ibuffer-hook
	    (lambda ()
	      (ibuffer-projectile-set-filter-groups)
	      (unless (eq ibuffer-sorting-mode 'alphabetic)
		((insert) buffer-do-sort-by-alphabetic))))
  )

(use-package smartparens-config
    :ensure smartparens
    :commands (turn-on-smartparens-strict-mode)
    ;; :demand t
    :init
    (progn
      (add-hook 'racket-mode-hook #'turn-on-smartparens-strict-mode)
      (add-hook 'racket-repl-mode-hook #'turn-on-smartparens-strict-mode)
      (add-hook 'lisp-mode-hook #'turn-on-smartparens-strict-mode)
      (add-hook 'emacs-lisp-mode-hook #'turn-on-smartparens-strict-mode))
    :config
    (progn
      (setq sp-show-pair-delay 0)
      (show-smartparens-global-mode t))
    :bind
    (:map smartparens-mode-map
          ("C-M-f" . sp-forward-sexp)
          ("C-M-b" . sp-backward-sexp)

          ("C-M-d" . sp-down-sexp)
          ("C-M-e" . sp-up-sexp)

          ("C-M-a" . sp-backward-down-sexp)
          ("C-M-u" . sp-backward-up-sexp)

          ("C-S-d" . sp-beginning-of-sexp)
          ("C-S-a" . sp-end-of-sexp)

          ("C-M-n" . sp-next-sexp)
          ("C-M-p" . sp-previous-sexp)

          ("C-M-k" . sp-kill-sexp)
          ("C-M-w" . sp-copy-sexp)

          ("M-[" . sp-backward-unwrap-sexp)
          ("M-]" . sp-unwrap-sexp)

          ("C-)" . sp-forward-slurp-sexp)
          ("C-(" . sp-forward-barf-sexp)
          ("C-M-)"  . sp-backward-slurp-sexp)
          ("C-M-("  . sp-backward-barf-sexp)

          ("M-D" . sp-splice-sexp)
          ("C-M-<delete>" . sp-spilce-sexp-killing-forward)
          ("C-M-<backspace>" . sp-splice-sexp-killing-backward)
          ("C-S-<backspace>" . sp-splice-sexp-killing-around)

          ("C-]" . sp-select-next-thing-exchange)
          ("C-M-]" . sp-select-next-thing)

          ("M-F" . sp-forward-symbol)
          ("M-B" . sp-backward-symbol)
          ("M-q" . sp-indent-defun)
          ("M-r" . sp-raise-sexp)))

(use-package electric
  :ensure t
  :init
  (progn
    (electric-pair-mode 1))
  (setq electric-pair-pairs
	'(
          (?\" . ?\")
	  (?\' . ?\')
	  (?\[ . ?\])
          (?\{ . ?\}))))

(use-package rainbow-delimiters
  :ensure t
  :commands rainbow-delimiters-mode
  :init
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(setq tramp-default-method "ssh")
(use-package expand-region
  :ensure t
  :commands (er/expand-region
             er/mark-inside-pairs
             er/mark-inside-quotes
             er/mark-outside-pairs
             er/mark-outside-quotes
             er/mark-defun
             er/mark-comment
             er/mark-text-sentence
             er/mark-text-paragraph
             er/mark-word
             er/mark-url
             er/mark-email
             er/mark-symbol)
  :bind("C-=" . er/expand-region))

;; (setq ido-create-new-buffer 'always)
;; (setq ido-file-extensions-order '(".org" ".txt" ".py" ".emacs" ".xml" ".el" ".ini" ".cfg" ".cnf"))

;; mwim
(use-package mwim
  :ensure t
  :bind(("C-a" . mwim-beginning)
	("C-e" . mwim-end)))


(setq org-src-window-setup 'current-window)
(setq org-confirm-babel-evaluate nil)
(setq org-src-preserve-indentation t)

;; pdf-tools
;; http://alberto.am/2020-04-11-pdf-tools-as-default-pdf-viewer.html
(use-package pdf-tools
  ;; :ensure t
  :pin manual
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-width)
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
  (define-key pdf-view-mode-map (kbd "C-r") 'isearch-backward)
  :custom
  (pdf-annot-activate-created-annotations t "automatically annotate highlights"))
(setq TeX-view-program-selection '((output-pdf "PDF Tools"))
      TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
      TeX-source-correlate-start-server t)

(add-hook 'TeX-after-compilation-finished-functions
          #'TeX-revert-document-buffer)

;; ;; org-pdf-tools
;; (use-package org-pdftools
;;   :hook (org-load . org-pdftools-setup-link))

;; (use-package org-noter-pdftools
;;   :after org-noter
;;   :config
;;   (with-eval-after-load 'pdf-annot
;;     (add-hook 'pdf-annot-activate-handler-functions #'org-noter-pdftools-jump-to-note)))

;; (eval-after-load 'org '(require 'org-pdfview))

;; (add-to-list 'org-file-apps '("\\.pdf\\'" . (lambda (file link) (org-pdfview-open link))))

;; winner mode
;; (winner-mode t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;IDO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; https://www.masteringemacs.org/article/introduction-to-ido-mode
;; https://github.com/lewang/flx
;; flx-ido - https://github.com/lewang/flx
;; ido - https://www.emacswiki.org/emacs/InteractivelyDoThings
(use-package ido
  :config
  (setq ido-enable-prefix nil
	ido-enable-flex-matching t
	ido-create-new-buffer 'always
	ido-use-filename-at-point 'guess
	ido-max-prospects 10
	ido-default-file-method 'selected-window
	ido-auto-merge-work-directories-length nil
	ido-use-faces nil
	)
  (ido-mode t)
  (ido-everywhere 1))

(use-package flx-ido
  :ensure t
  :config
  (flx-ido-mode +1)
  ;; disable ido faces to see flx highlights
  (setq ido-use-faces nil)
  )

;; https://clangd.llvm.org/installation.html
;; https://emacs-lsp.github.io/lsp-mode/tutorials/CPP-guide/

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-file-apps
   '((auto-mode . emacs)
     (directory . emacs)
     ("\\.mm\\'" . default)
     ("\\.x?html?\\'" . default)
     ("\\.pdf\\'" . emacs)))
 '(package-selected-packages
   '(yaml-mode dockerfile-mode qml-mode diminish go-mode pretty-mode ob-ipython saveplace-pdf-view lsp-ui smartparens rainbow-delimiters ace-window multiple-cursors which-key cask dash-functional dash flx-ido lsp-python-ms company posframe helm-projectile lsp-mode diredfl treemacs-icons-dired restclient rg counsel-projectile projectile emmet-mode yasnippet-snippets dap-mode cmake-mode snippet major-mode-hydra pretty-hydra openwith org-noter-pdftools org-pdftools pdf-tools org-bullets use-package doom-themes expand-region mwim electric-operator counsel smex swiper avy ivy flycheck)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-ellipsis ((t (:foreground nil)))))
