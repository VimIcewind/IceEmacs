;;启动设置
(setq default-frame-alist
      ' ((vertical-scroll-bars)
	 ;;1366x768
	 (top . 34)
	 (left . 347)
	 ;;1440x900
	 ;;(top . 82)
	 ;;(left . 385)
	 ;;1920x1080
	 ;;(top . 166)
	 ;;(left . 623)
	 (width . 80)
	 (height . 38)
	 (background-color . "black")
	 (foreground-color . "grey")
	 (cursor-color     . "gold1")
	 (mouse-color      . "gold1")
	 (tool-bar-lines . 0)
	 (menu-bar-lines . 0)
	 (right-fringe)
	 (left-fringe)))

;;禁止显示启动画面
;;(setq inhibit-startup-message t)

;;改变Emacs固执的要你回答yes的行为。按y或空格键表示yes，n表示no。
(fset 'yes-or-no-p 'y-or-n-p)

;;插件目录
(add-to-list 'load-path' "~/.emacs.d/plugin")
;;(add-to-list 'load-path' "D:/Emacs/.emacs.d/plugin")

;;菜单栏
;;(menu-bar-mode t)
;;工具栏
(tool-bar-mode -1)

;;(setenv "HOME" "D:/Emacs")
;;(setenv "PATH" "D:/Emacs")

;;设置ctags的目录,设置Emacs的c源代码目录
;; check OS type
(cond
 ((string-equal system-type "windows-nt") ; Microsoft Windows
  (setq path-to-ctags "D:/Vim/tools/ctags.exe")
  (setq source-directory "E:/GitHub/emacs/")
  (progn
    (message "Microsoft Windows")))
 ((string-equal system-type "darwin") ; Mac OS X
  (progn
    (message "Mac OS X")))
 ((string-equal system-type "gnu/linux") ; linux
  (setq path-to-ctags "/usr/bin/ctags")
  (setq source-directory "/root/GitHub/emacs/")
  (progn
    (message "Linux"))))

(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (shell-command
   (format "%s -f TAGS -e -R %s" path-to-ctags (directory-file-name dir-name)))
)

;;设置Emacs的c源代码目录
;;(setq source-directory "D:/Emacs/")
(setq source-directory "/root/GitHub/emacs/")
;;(setq todo-file-do "D:/Todo/do")
;;(setq todo-file-done "D:/Todo/done")
;;(setq todo-file-top "D:/Todo/top")

;;显示行号列号
(column-number-mode t)
;;设置C-x O回到原来窗口
(global-set-key (kbd "C-x O") 'previous-multiframe-window)
;;设置标记点
;;(global-set-key (kbd "M-SPC") 'set-mark-command)
;;(global-set-key (kbd "M-m") 'set-mark-command)
;;指针不要闪
;; (blink-cursor-mode nil)
;; (transient-mark-mode t)
;;鼠标自动避开指针
(mouse-avoidance-mode 'animate)
;;自动显示所匹配的另一个括号
(show-paren-mode t)
;;光标不会跳到另一个括号处
(setq show-paren-style 'parentheses)

;;不产生备份文件
(setq auto-save-default nil)
(setq make-backup-files nil)
;;不产生临时文件
(setq-default make-backup-files nil)

;;定制C/C++的Linux缩进风格
(add-hook 'c-mode-hook
	  '(lambda()
	     (c-set-style "linux")
	     (c-toggle-auto-state)
	     (c-toggle-auto-hungry-state)
	     ;;设置缩进字符数
	     (setq c-basic-offset 4)
	     (setq indent-tabs-mode nil)))
(add-hook 'c++-mode-hook
	  '(lambda()
	     (c-set-style "stroustrup")
	     (c-toggle-auto-state)
	     (c-toggle-auto-hungry-state)
	     ;;设置缩进字符数
	     (setq c-basic-offset 4)
	     (setq indent-tabs-mode nil)))
;;换行后立即缩进
(global-set-key (kbd "RET") 'newline-and-indent)

;;自动侦测文件编码gb2312或utf-8
(if (equal current-language-environment "UTF-8")
    (prefer-coding-system 'gb2312)
  (prefer-coding-system 'utf-8))

;;(set-language-environment 'UTF-8)

;;;; c-mode设置
;;;; c-mode公共设置
;;(defun my-c-mode-common-hook ()
;;  (setq default-tab-width 8)
;;  (setq tab-width 8)
;;  (setq c-basic-offset 8)
;;  (hs-minor-mode t))
;;(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;;启动gdb-many-windows时加载的钩子函数，改变many-windows的默认布局，这个钩子函数不能勾在gdb-setup-windows，因为此时assamble-buffer还没完成初始化，不能set到window
(defadvice gdb-frame-handler-1 (after activate)
  (if gdb-use-separate-io-buffer
      (advice_separate_io)
    (advice_no_separate_io)))

;;生成没有单独IO窗口的gdb布局
(defun advice_no_separate_io()
  ;;默认的生成gdb-assembler-buffer的函数本身也会设计调用gdb-frame-handler-1，加入此条件发生避免无限递归调用
  (if (not (gdb-get-buffer 'gdb-assembler-buffer))
      (progn
	(shrink-window-horizontally ( / (window-width) 3))

	(other-window 1)
	(split-window-horizontally)

	(other-window 1)
	(gdb-set-window-buffer (gdb-stack-buffer-name))

	(other-window 1)
	(split-window-horizontally)

	(other-window 1)
	(gdb-set-window-buffer (gdb-get-buffer-create 'gdb-assembler-buffer))

	(split-window-horizontally  (/ ( * (window-width) 2) 3))

	(other-window 1)
	(gdb-set-window-buffer (gdb-get-buffer-create 'gdb-registers-buffer))

	(other-window 1)
	(toggle-current-window-dedication)
	(gdb-set-window-buffer (gdb-get-buffer-create 'gdb-memory-buffer))
	(toggle-current-window-dedication)

	(other-window 2)
	)))

;;生成有单独IO窗口的gdb布局
(defun advice_separate_io()
  ;;默认的生成gdb-assembler-buffer的函数本身也会设计调用gdb-frame-handler-1，加入此条件发生避免无限递归调用
  (if (not (gdb-get-buffer 'gdb-assembler-buffer))
      (progn
	(split-window-horizontally)
	(enlarge-window-horizontally ( / (window-width) 3))
	(other-window 1)

	;;此处不能使用(gdb-set-window-buffer (gdb-get-buffer-create 'gdb-inferior-io))代替，
	;;因为在打开gdb-use-separate-io-buffer的状态时，它还会额外调用一些函数将gdb的input，output定位到该buffer
	(gdb-set-window-buffer (gdb-inferior-io-name))

	(other-window 1)
	(split-window-horizontally)

	(other-window 1)
	(gdb-set-window-buffer (gdb-stack-buffer-name))

	(other-window 1)

	(other-window 1)
	(toggle-current-window-dedication)
	(gdb-set-window-buffer (gdb-get-buffer-create 'gdb-assembler-buffer))
	(toggle-current-window-dedication)

	(split-window-horizontally  (/ ( * (window-width) 2) 3))

	(other-window 1)
	(gdb-set-window-buffer (gdb-get-buffer-create 'gdb-registers-buffer))

	(other-window 1)
	(toggle-current-window-dedication)
	(gdb-set-window-buffer (gdb-get-buffer-create 'gdb-memory-buffer))
	(toggle-current-window-dedication)

	(other-window 2)
	)))
;;shell,gdb退出后，自动关闭该buffer
(add-hook 'shell-mode-hook 'mode-hook-func)
(add-hook 'gdb-mode-hook 'mode-hook-func)
(defun mode-hook-func ()
  (set-process-sentinel (get-buffer-process (current-buffer))
			#'kill-buffer-on-exit)
  )
(defun kill-buffer-on-exit (process state)
  (message "%s" state)
  (if (or
       (string-match "exited abnormally with code.*" state)
       (string-match "finished" state))
      (kill-buffer (current-buffer))))
(global-set-key [(f6)] 'gdb)
(setq gdb-many-windows t)

;;;; Fonts setting
;; 设置两个字体变量，一个中文的一个英文的
;; 之所以两个字体大小是因为有的中文和英文相同字号的显示大小不一样，需要手动调整一下。
(setq cjk-font-size 15)
(setq ansi-font-size 15)

;; 设置一个字体集，用的是create-fontset-from-fontset-spec内置函数
;; 中文一个字体，英文一个字体混编。显示效果很好。
(defun set-font()
  (interactive)
  (create-fontset-from-fontset-spec
   (concat
    "-*-fixed-medium-r-normal-*-*-*-*-*-*-*-fontset-myfontset,"
    (format "ascii:-outline-Consolas-normal-normal-normal-mono-%d-*-*-*-c-*-iso8859-1," ansi-font-size)
    (format "unicode:-microsoft-Microsoft YaHei-normal-normal-normal-*-%d-*-*-*-*-0-iso8859-1," cjk-font-size)
    (format "chinese-gb2312:-microsoft-Microsoft YaHei-normal-normal-normal-*-%d-*-*-*-*-0-iso8859-1," cjk-font-size)
    ;; (format "unicode:-outline-文泉驿等宽微米黑-normal-normal-normal-sans-*-*-*-*-p-*-gb2312.1980-0," cjk-font-size)
    ;; (format "chinese-gb2312:-outline-文泉驿等宽微米黑-normal-normal-normal-sans-*-*-*-*-p-*-gb2312.1980-0," cjk-font-size)
    )))

;; 函数字体增大，每次增加2个字号，最大48号
(defun increase-font-size()
  "increase font size"
  (interactive)
  (if (< cjk-font-size 48)
      (progn
	(setq cjk-font-size (+ cjk-font-size 2))
	(setq ansi-font-size (+ ansi-font-size 2))))
  (message "cjk-size:%d pt, ansi-size:%d pt" cjk-font-size ansi-font-size)
  (set-font)
  (sit-for .5))

;; 函数字体增大，每次减小2个字号，最小2号
(defun decrease-font-size()
  "decrease font size"
  (interactive)
  (if (> cjk-font-size 2)
      (progn
	(setq cjk-font-size (- cjk-font-size 2))
	(setq ansi-font-size (- ansi-font-size 2))))
  (message "cjk-size:%d pt, ansi-size:%d pt" cjk-font-size ansi-font-size)
  (set-font)
  (sit-for .5))

;; 恢复成默认大小16号
(defun default-font-size()
  "default font size"
  (interactive)
  (setq cjk-font-size 15)
  (setq ansi-font-size 15)
  (message "cjk-size:%d pt, ansi-size:%d pt" cjk-font-size ansi-font-size)
  (set-font)
  (sit-for .5))

;; 只在GUI情况下应用字体。Console时保持终端字体。
(if window-system
    (progn
      (set-font)
      ;; 把上面的字体集设置成默认字体
      ;; 这个字体名使用是create-fontset-from-fontset-spec函数的第一行的最后两个字段
      (set-frame-font "fontset-myfontset")

      ;; 鼠标快捷键绑定
      (global-set-key '[C-wheel-up] 'increase-font-size)
      (global-set-key '[C-wheel-down] 'decrease-font-size)
      ;; 键盘快捷键绑定
      (global-set-key (kbd "C--") 'decrease-font-size) ;Ctrl+-
      (global-set-key (kbd "C-0") 'default-font-size)  ;Ctrl+0
      (global-set-key (kbd "C-=") 'increase-font-size) ;Ctrl+=
      ))


;;(add-to-list 'exec-path "D:/w3m")
;;(require 'w3m-load)
;;(setq w3m-use-favicon nil)
;;(setq w3m-command-arguments '("-cookie" "-F"))
;;(setq w3m-use-cookies t)
;;(setq w3m-home-page "http://www.baidu.com")

;;自动括号补全
(require 'autopair)
(autopair-global-mode)

;;如果使用sql-mysql模式出现输入sql没有回显。
(setq sql-mysql-options '("-C" "-t" "-f" "-n"))

;;在linum-mode下，行号至少占3列并且后面空一列
(setq linum-format "%3d ")

