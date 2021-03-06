;;; yui-mode --- A mode to ensure proper indentation of YUI Javascript.

;; Copyright (C) 2015 Geoffrey J. Teale

;; Author: Geoffrey J. Teale <geoffrey.teale@canonical.com>
;; Maintainer: Geoffrey J. Teale <geoffrey.teale@canonical.com>
;; Keywords: convenience languages javacscript YUI

;;; Commentary:
;;    yui-mode ignores YUI boiler plate when indenting javascript.

;;; Code:


(defun yui-point-at-end-of-opening-boilerplate ()
  "Return the point (as an integer) at the end of the YUI.add boilerplate."
  (save-excursion
    (goto-char (point-min))
    (let ((found-opening nil)
          (found-function nil))
      (while (not found-opening)
        (setq found-opening (looking-at "^YUI[\(\)]*\.[a\|\|u][d\|\|s][d\|\|e].*"))
        (if (not found-opening)
            (forward-line)))
      (while (not found-function)
        (setq found-function (looking-at ".*function\(Y\).*"))
        (forward-line)))
    (point)))

(defun yui-point-at-beginning-of-closing-boilerplate ()
  "Return the point (as an integer) at the begining of the end of the YUI.add boilerplate."
  (save-excursion
    (goto-char (point-max))
    (let ((seen-close nil)
          (early-exit nil))
      (while (not (or early-exit (looking-at "^}, \"[0-9.]*\", {\"requires\":.*")))
        (setq seen-close (or seen-close (looking-at "^.*\);")))
        (if (and seen-close (looking-at "^[ \t]*$"))
            (setq early-exit t)
          (forward-line -1))))
    (backward-char)
    (point)))

(defun yui-narrow-to-non-boilerplate-region ()
  "Narrow the buffer, excluding the YUI.add boilerplate."
  (interactive)
  (let ((beginning (yui-point-at-end-of-opening-boilerplate))
        (end (yui-point-at-beginning-of-closing-boilerplate)))
    (narrow-to-region beginning end)))

(defun indent-yui-region (start end &optional column)
  "Indent a region, excluding the YUI.add boilerplate.  START and END may be modified for this purpose, but COLUMN, if passed will be handend on 'indent-region' untouched."
  (interactive "r\nP")
  (let* ((b-end (yui-point-at-end-of-opening-boilerplate))
         (b-start (yui-point-at-beginning-of-closing-boilerplate))
         (real-start (if (< start b-end) b-end start))
         (real-end (if (> end b-start) b-start end)))
    (save-restriction
      (narrow-to-region b-end b-start)
      (indent-region real-start real-end column))))

(defun indent-yui-for-tab-command (&optional arg)
  "Indent the current line or region (ignoring the YUI.add boilerplate), or insert a tab, as appropriate.  Optionally ARG is passed through to 'indent-for-tab-command'."
  (interactive "P")
  (save-restriction
    (yui-narrow-to-non-boilerplate-region)
    (indent-for-tab-command arg)))

(defvar yui-mode-map (make-sparse-keymap)
  "Keymap for YUI minor mode.")


(define-key yui-mode-map (kbd "TAB") #'indent-yui-for-tab-command)
(define-key yui-mode-map (kbd "C-M-\\") #'indent-yui-region)

;;;###autoload
(define-minor-mode yui-mode
  "A minor mode to indent YUI properly."
  nil
  :lighter " yui-mode"
  yui-mode-map)

;;;###autoload
(defun turn-on-yui-mode ()
  "Turn on yui-mode."
  (interactive)
  (yui-mode 1))

;;;###autoload
(defun turn-off-yui-mode ()
  "Turn off yui-mode."
  (interactive)
  (yui-mode -1))

;;;###autoload
(define-globalized-minor-mode global-yui-mode yui-mode turn-on-yui-mode)

(provide 'yui-mode)
;;; yui-mode.el ends here
