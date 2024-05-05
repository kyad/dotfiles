;;; init.el --- My init.el  -*- lexical-binding: t; -*-

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; My init.el.

;;; Code:

;; this enables this running method
;;   emacs -q -l ~/.debug.emacs.d/init.el

(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org"   . "https://orgmode.org/elpa/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; ここにいっぱい設定を書く
(leaf-keys (("C-h" . backward-delete-char)))

(leaf cus-start
  :doc "define customization properties of builtins"
  :tag "builtin" "internal"
  :custom '((menu-bar-mode . nil)
            (tool-bar-mode . nil)
            (scroll-bar-mode . nil)
            (indent-tabs-mode . nil)
            (inhibit-startup-message . t)
            (initial-scratch-message . "")
            (line-number-mode . t)))

(leaf leaf
  :config
  (leaf leaf-convert
    :ensure t)
  (leaf use-package
    :ensure t))

;; sudo apt install silversearcher-ag  # ag, counsel-ag
(leaf ag
  :ensure t)

(leaf autorevert
  :custom ((auto-revert-interval . 1))
  :global-minor-mode global-auto-revert-mode)

(leaf recentf
  :ensure t
  :init (recentf-mode 1))

(leaf paren
  :doc "highlight matching paren"
  :tag "builtin"
  :custom ((show-paren-delay . 0.1))
  :global-minor-mode show-paren-mode)

(leaf ivy
  :doc "Incremental Vertical completYon"
  :req "emacs-24.5"
  :tag "matching" "emacs>=24.5"
  :url "https://github.com/abo-abo/swiper"
  :emacs>= 24.5
  :ensure t
  :blackout t
  :leaf-defer nil
  :custom ((ivy-initial-inputs-alist . nil)
           (ivy-use-selectable-prompt . t)
           ;(ivy-sort-functions-alist . 'ivy-prescient-enable-sorting)
           )
  :global-minor-mode t
  :config
  (leaf swiper
    :ensure t
    :bind (("C-M-s" . swiper)))
  (leaf counsel
    :doc "Various completion functions using Ivy"
    :req "emacs-24.5" "swiper-0.13.0"
    :url "https://github.com/abo-abo/swiper"
    :emacs>= 24.5
    :ensure t
    :blackout t
    :bind (("C-S-s" . counsel-imenu)  ;; バッファの代表的な行(関数宣言など)を一覧する
           ("C-M-S-s" . counsel-ag)
           ("C-x C-r" . counsel-recentf))  ;; 最近開いたファイルを一覧する
    :custom `((counsel-yank-pop-separator . "\n----------\n")
              (counsel-find-file-ignore-regexp . ,(rx-to-string '(or "./" "../") 'no-group)))
    :global-minor-mode t))

;; counsel-find-file を使わない
;; completion-in-region-function も一時的にデフォに戻さないと，TAB補完時に
;; ivy が有効化されてしまう．
(defun my-disable-counsel-find-file (&rest args)
  "Disable `counsel-find-file' and use the original `find-file' with ARGS."
  (let ((completing-read-function #'completing-read-default)
        (completion-in-region-function #'completion--in-region))
    (apply #'read-file-name-default args)))
(setq read-file-name-function #'my-disable-counsel-find-file)
;; (counsel-mode 1) を設定しても counsel-find-file が呼ばれないようにする．
(define-key counsel-mode-map [remap find-file]  nil)

(leaf prescient
  :doc "Better sorting and filtering"
  :req "emacs-25.1"
  :url "https://github.com/raxod502/prescient.el"
  :emacs>= 25.1
  :ensure t
  :custom ((prescient-aggressive-file-save . t)
           (prescient-filter-method . '(literal-prefix literal regexp initialism)))  ;; compと入力した時にrecompileよりもcompileを先にする
  :global-minor-mode prescient-persist-mode)
  
(leaf ivy-prescient
  :doc "prescient.el + Ivy"
  :req "emacs-25.1" "prescient-4.0" "ivy-0.11.0"
  :url "https://github.com/raxod502/prescient.el"
  :emacs>= 25.1
  :ensure t
  :after prescient ivy
  :custom ((ivy-prescient-retain-classic-highlighting . t))
  :global-minor-mode t)

(leaf yasnippet
  :ensure t
  :init (yas-global-mode 1)
  :bind ((yas-minor-mode-map
          ("C-x i i" . yas-insert-snippet)
          ("C-x i l" . yas-describe-tables)
          ("C-x i n" . yas-new-snippet)
          ("C-x i v" . yas-visit-snippet-file)))
  :custom
  (yas-snippet-dirs . '("~/.emacs.d/mysnippets")))

(leaf beacon
  :ensure t
  :init (beacon-mode 1)
  :custom ((beacon-size . 16)))  ;; dired-modeで改行が入らないようにするため短かくする

(leaf multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . 'mc/edit-lines)
         ("C->" . 'mc/mark-next-like-this-word)
         ("C-<" . 'mc/mark-previous-like-this-word)
         ("C-c C-<" . 'mc/mark-all-like-this)))

(leaf dired
  :require t
  :custom ((dired-dwim-target . t)
           (dired-recursive-copies . 'always)
           (dired-isearch-filenames . t)))

;; echo 'Emacs*useXIM: false' >> ~/.Xresources
(unless (locate-library "skk")
  (package-install 'ddskk t))
(leaf skk
  :ensure ddskk
  :bind (("C-x j" . skk-mode))  ;; Avoid fill-mode
  :custom ((default-input-method . "japanese-skk"))
  :config
  (leaf ddskk-posframe
    :ensure t
    :global-minor-mode t))

;; echo 'lang en_US' >> ~/.aspell.conf
(leaf ispell
  :if (file-executable-p "aspell")
  :custom
  (ispell-program-name . "aspell")
  :config
  (add-to-list 'ispell-skip-region-alist '("[^\000-\377]+")))

(leaf magit
  :ensure t)

;; M-x all-the-icons-install-fonts
(leaf all-the-icons
  :if (display-graphic-p)
  :ensure t
  :config
  (leaf all-the-icons-ivy
    :ensure t
    :hook (after-init-hook . all-the-icons-ivy-setup))
  (leaf all-the-icons-dired
    :ensure t
    :hook (dired-mode-hook . all-the-icons-dired-mode)))

(leaf ein
  :ensure t)

(leaf persistent-scratch
  :ensure t
  :config
  (persistent-scratch-setup-default))

;; sudo apt install clangd
;; sudo apt install python3-pip python-is-python3
;; pip install python-lsp-server[all]
(leaf eglot
  :ensure t
  :hook
  (c++-mode-hook . eglot-ensure)
  (python-mode-hook . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
               '(python-mode "~/.local/bin/pylsp")))

;; eglotのflymakeでメッセージをカーソル位置に出す
(leaf flymake-diagnostic-at-point
  :ensure t
  :after flymake
  :hook (flymake-mode-hook . flymake-diagnostic-at-point-mode)
  :custom ((flymake-diagnostic-at-point-timer-delay . 0)))

(leaf company
  :ensure t
  :after yasnippet
  :init
  (global-company-mode)
  :custom
  ((company-backends . `(
                         company-bbdb
                         company-semantic
                         company-cmake
                         ;company-capf
                         ;company-clang
                         company-files
                         (company-dabbrev-code company-gtags company-etags company-keywords)
                         company-oddmuse
                         company-dabbrev))
   (company-idle-delay . 3)
   (company-selection-default . nil)
   (company-transformers . nil))  ;; 辞書順
  :config
  ;; yasnippetとの連携 https://github.com/keicy/.emacs.d/issues/75
  (defvar company-mode/enable-yas t
    "Enable yasnippet for all backends.")
  (defun company-mode/backend-with-yas (backend)
    (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
        backend
      (append (if (consp backend) backend (list backend))
              '(:with company-yasnippet))))
  (defun set-yas-as-company-backend ()
    (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends)))
  (add-hook 'company-mode-hook 'set-yas-as-company-backend)
  )

(if (and (display-graphic-p) (boundp 'window-system))
    (cond
     ((>= (x-display-pixel-height) 1440)  ;; >=WQHD
      (progn
        (set-face-font 'default "migu 1m-12")
        ;; (set-face-font 'default "HackGen Console NF-12")
        (add-to-list 'default-frame-alist '(width . 150))
        (add-to-list 'default-frame-alist '(height . 70))
        (add-to-list 'default-frame-alist '(left . 1300))
        (add-to-list 'default-frame-alist '(top . 0))))
     ((>= (x-display-pixel-height) 1080)  ;; >=FHD
      (progn
        (set-face-font 'default "migu 1mF-10")
        ;; (set-face-font 'default "HackGen Console NF-10")
        (add-to-list 'default-frame-alist '(width . 100))
        (add-to-list 'default-frame-alist '(height . 60))
        (add-to-list 'default-frame-alist '(left . 1000))
        (add-to-list 'default-frame-alist '(top . 0))))
     nil))

(leaf web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist
               '("\\.ts[x]?\\'" . web-mode)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(compile-command "g++-12 -std=gnu++2b -O0 -g3 -Wall -Wextra -I${HOME}/ac-library a.cc")
 '(frame-title-format "%f" t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(initial-scratch-message "")
 '(line-number-mode t)
 '(menu-bar-mode nil)
 '(package-archives
   '(("gnu" . "https://elpa.gnu.org/packages/")
     ("melpa" . "https://melpa.org/packages/")
     ("org" . "https://orgmode.org/elpa/")))
 '(package-selected-packages '(blackout el-get hydra leaf-keywords leaf))
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(provide 'init)
;;; init.el ends here
