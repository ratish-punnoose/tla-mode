;;; tla-mode.el --- TLA+ language support for Emacs

;; Copyright (C) 2015-2019 Ratish Punnoose

;; Author: Ratish Punnoose
;; Version: 1.1
;; URL: https://github.com/ratish-punnoose/tla-mode
;; Originally Created: 8 Jun 2015
;; Modified: Apr 2019

;;; Commentary:
;; USAGE
;; =====
;; The tla mode should be loaded when a file with extension .tla is
;; read in. The mode performs the following basic functions:
;; 1. Highlighting of keywords
;; 2. Prettify symbols.
;;    This is done using unicode symbol substitution for the ascii
;;    representations of TLA operators.  This is only performed if a
;;    suitable font to handle the symbol is available in the fontset.
;; 3. Simple indentation
;;    For this to be useful, the font that handles the symbols should
;;    be fixed-width and match the width of the primary font.


;;; Code:

(require 'seq)

(defvar tla-mode-map
   (let ((map (make-sparse-keymap)))
     map)
   "Keymap for `tla-mode'.")

(defvar tla-mode-constants
    '("FALSE"
      "TRUE"))

(defvar tla-mode-keywords
  '("MODULE" "EXTENDS" "INSTANCE" "WITH"
    "LOCAL"
    "CONSTANT" "CONSTANTS" "VARIABLE" "VARIABLES"
    "IF" "THEN" "ELSE"
    "CHOOSE" "CASE" "OTHER"
    "LET"
    "RECURSIVE"
    "ENABLED" "UNCHANGED"
    "SUBSET" "UNION"
    "DOMAIN" "EXCEPT"
    "SPEC" "LAMBDA"
    "THEOREM" "ASSUME" "NEW" "PROVE"
    ;; Keywords for proofs
    "PROOF" "OBVIOUS" "OMITTED" "BY" "QED"
    "SUFFICES" "PICK" "HAVE" "TAKE" "WITNESS"
    "ACTION" "STATE" "WF" "SF"
    ))

(defvar tla-mode-types
  '("Int" "BOOLEAN"))

(defvar tla-tab-width 2 "Width of a tab.")

(defvar tla-template-by-default t
  "If t then auto insert a tla template into empty files.")

(defun tla-fixcase-keywords (beg end length)
  "Automatically fix case for keywords."
  ;; 1. Check if region is small. based on beg/end.
  ;;   if small then go back one, check thing at point and upcase it.
  ;; 2. If region is larger, then start at beg and go forward one word
  ;;   at a time until end. check thing at point and upcase.
  (cond ((and (= (- end beg) 1)
              (eq (car (syntax-after (1- end))) 0))
         (save-excursion
           (backward-char 1)
           (let ((curr-word (thing-at-point 'word t)))
             (when (and (stringp curr-word)
                        (member (upcase curr-word) tla-mode-keywords))
               (backward-word)
               (upcase-word 1)))
        ))))

(defun tla-stop-keywordfix ()
  "Remove tla hook to auto upcase keywords."
  (interactive)
  (remove-hook 'after-change-functions 'tla-fixcase-keywords  t))


(defun tla-get-indent-of (prev curr-col)
  "Indent current location to a previous text symbol"
  (let ((indent-col 0)
        (curr-col (current-column))
        (curr-line 0))
    (setq curr-line (line-number-at-pos))
    (save-excursion
      (search-backward prev 0 t)
      (cond ((or (not (match-string 0)) ; no find
                 (= curr-line (line-number-at-pos))) ; find on
                                        ; same line
             (setq indent-col curr-col)) ;; No better than current column
            (t
             (setq indent-col (current-column)))))
    indent-col))



(defun tla-template ()
  "Insert a TLA template"
  (interactive)
  (let ((this-file-name (buffer-file-name)) ; absolute file name or nil
        (insertion-point 0)
        (fill-len 0)) ;; Extra chars on first line to get to 80
    (when this-file-name          ;; for legal files
      (goto-char 1)               ;; at beginning of file
      (setq this-file-name
            (file-name-sans-extension
             (file-name-nondirectory
              this-file-name)))
      (setq fill-len
        (- 80
           (+ 13 (string-width this-file-name))))
      (setq fill-len
            (if (< fill-len 0) 0  fill-len))
      (insert
       (make-string 4 ?-)         ;; 4 dashes
       " MODULE "
       this-file-name
       " "
       (make-string fill-len ?-)
       "\n"
       "(* Documentation *)\n"
       (make-string 80 ?-)
       "\n")
      (setq insertion-point (point))
      (insert
       "\n"
       (make-string 80 ?=)
       "\n\n"
       )
      (goto-char insertion-point)
      )
    ))


(defun tla-indent-line ()
  "Indent line for tla-mode."
  (interactive)
  ;; If there is preceding text on the line then do different type of
  ;; indentation (padding)
  ;;
  ;; 1. If text present, then tab lines up with ==
  ;; 2. If looking back at end/else, find matching block and indent accordingly.
  ;;

  (let ((indent-col 0)
        (curr-col (current-column))
        (curr-line 0))  ;;(case-fold-search t)) ;; case-sensitive search
    (cond ((or (= 0 curr-col)
               (looking-back "^[[:blank:]]*"))
                                        ; No text before cursor on current line
           (cond
            ((looking-at "[[:blank:]]*THEN")
             (search-forward "THEN" (point-at-eol) t)
             (setq indent-col (tla-get-indent-of "IF" curr-col))
             (indent-line-to indent-col))

            ((looking-at "[[:blank:]]*ELSE")
             (search-forward "ELSE" (point-at-eol) t)
             (setq indent-col (tla-get-indent-of "THEN" curr-col))
             (indent-line-to indent-col))

            (t ;
             (save-excursion
               (setq indent-col
                     ;;(beginning-of-line)
                     (condition-case nil
                         (progn
                           (forward-line -1) ; go up one line
                           (if (> curr-col 0)
                               (move-to-column (+ 1 curr-col)))
                           (cond ((re-search-forward "\\(/\\\\\\|\\\\/\\|IF\\|THEN\\|ELSE\\)"
                                                     (line-end-position)
                                                     t)
                                  ;; if search successful
                                  (goto-char (match-beginning 0))
                                  (current-column))
                                 (t
                                        ; no match
                                  (current-indentation))))
                       (error 0))))
             (indent-line-to indent-col))))

          ;; after else
          ((looking-back  "[[:blank:]]*ELSE[[:blank:]]*"
                         (point-at-bol))
           (search-backward "ELSE" (point-at-bol) t)
           (setq indent-col (tla-get-indent-of "THEN" curr-col))
           (beginning-of-line)
           (indent-line-to indent-col)
           (end-of-line))

          ; after then
          ((looking-back  "[[:blank:]]*THEN[[:blank:]]*"
                         (point-at-bol))
           (search-backward "THEN" (point-at-bol) t)
           (setq indent-col (tla-get-indent-of "IF" curr-col))
           (beginning-of-line)
           (indent-line-to indent-col)
           (end-of-line))

          (t ; look for ==
           (setq indent-col (tla-get-indent-of "==" curr-col))
           (indent-to-column indent-col))
          )))



(defvar tla-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?_ "w" st) ;; underscore is in word
    ;; open paren is start of two-character comment-start
    (modify-syntax-entry ?\( ". 1bn" st)
    ;; * is second character of comment-start or 1st char of
    ;; comment-end
    (modify-syntax-entry ?* ". 23" st)
    ;; close paren is end of two-character comment-end
    (modify-syntax-entry ?\) ". 4bn" st)

    ;; /* is a comment
    (modify-syntax-entry ?\\ ". 12b" st)
    (modify-syntax-entry ?\n "> b" st)
    ; Return st
    st
    )
  "Syntax table for tla-mode"
  )

(defvar tla-font-lock-defaults
  `((
     ;; stuff between "
     ("\"\\.\\*\\?" . font-lock-string-face)
     ;; ; : , ; { } =>  @ $ = are all special elements
     ;;(":\\|,\\|;\\|{\\|}\\|=>\\|@\\|$\\|=" . font-lock-keyword-face)
     ( ,(regexp-opt tla-mode-keywords 'words) . font-lock-keyword-face)
     ( ,(regexp-opt tla-mode-constants 'words) . font-lock-constant-face)
     ( ,(regexp-opt tla-mode-types 'words) . font-lock-type-face)
     )))

(defun tla-symbol-compose (elt)
  "add spaces to symbols to match indentation."
  (interactive)
  (let ((key (car elt))
        (len-of-key  (length (car elt)))
        (sym (cdr elt))
        (composelist '()))
    (cons key
          (cons sym
                (dotimes (i (1- len-of-key) composelist)
                  (push ?\s composelist)
                  (push '(Br . Bl) composelist))))))




;;;###autoload
(defvar tla-symbols-alist
  (mapcar
   'tla-symbol-compose
   (seq-filter
    ;; There is a list of symbols given here.
    ;; Not all may be printable based on the fonts available on a
    ;; system.
    ;; We filter in only the symbols for which there is a font
    ;; available.
    (lambda (elt) (internal-char-font 1 (cdr elt)))
    '(
      ("/\\" . ?∧)          ("\\land" . ?∧)
      ("\\/" . ?∨)          ("\\lor" . ?∨)
      ("=>" . ?⇒)
      ("~" . ?¬)
      ("\\lnot" . ?¬)       ("\\neg" . ?¬)
      ("<=>" . ?≡)          ("\equiv" . ?≡)
      ("==" . ?≜)
      ("\\in" . ?∈)
      ("\\notin" . ?∉)
      ("#" . ?≠)            ("/=" . ?≠)
      ("<<" . ?⟨)
      (">>" . ?⟩)
      ("[]" . ?□)
      ("<>" . ?◇)
      ("<=" . ?≤)           ("\\leq" . ?≤)
      (">=" . ?≥)           ("\\geq" . ?≥)
      ("~>" . ?↝)
      ("\\ll" . ?\《)
      ("\\gg" . ?\》)
      ("-+->" . ?⇸)
      ("\\prec" . ?≺)
      ("\\succ" . ?≻)
      ("|->" . ?↦)
      ("\\preceq" . ?⋞)
      ("\\succeq" . ?≽)
      ("\\div" . ?÷)
      ("\\subseteq" . ?⊆)
      ("\\supseteq" . ?⊇)
      ("\\cdot" . ?⋅)
      ("\\subset" . ?⊂)
      ("\\supset" . ?⊃)
      ("\\o" . ?∘) ("\\circ" . ?∘)
      ("\\sqsubset" . ?⊏)
      ("\\sqsupset" . ?⊐)
      ("\\bullet" . ?•)
      ("\\sqsubseteq" . ?⊑)
      ("\\sqsupseteq" . ?⊒)
      ("\\star" . ?⋆)
      ("|-" . ?⊢)
      ("-|" . ?⊣)
      ;; "\\bigcirc" no good rendering
      ("|=" . ?⊨)
      ;;"=|" no good rendering
      ("\\sim" . ?∼)
      ("->" . ?⭢)
      ("<-" . ?⭠)
      ("\\simeq" . ?≃)
      ("\\cap" . ?∩)          ("\\intersect" . ?∩)
      ("\\cup" . ?∪)          ("\\union" . ?∪)
      ("\\asymp" . ?≍)
      ("\\sqcap" . ?⊓)
      ("\\sqcup" . ?⊔)
      ("\\approx" . ?≈)
      ("(+)" . ?⊕)            ("\\oplus" . ?⊕)
      ("\\uplus" . ?⊎)
      ("\\cong" . ?≅)
      ("(-)" . ?⊖)            ("\\ominus" . ?⊖)
      ("\\X" . ?×)            ("\\times" . ?×)
      ("\doteq" . ?≐)
      ("(.)" . ?⊙)
      ;;
      ;;
      ;;
      ("\\E" . ?∃)
      ("\\A" . ?∀)
      ;;("\\EE" . ?∃)
      ;;("\\A" . ?∀)
      ("LAMBDA" . ?λ)))))


;;;###autoload
  ;;(set-char-table-parent table char-width-table)
  ;;  (setq char-width-table table)))



;;;###autoload
(define-derived-mode tla-mode prog-mode "TLA"
  "TLA mode is a major mode for writing TLA+ specifications"
  :syntax-table tla-mode-syntax-table

  (setq-local font-lock-defaults tla-font-lock-defaults)
  (setq-local indent-line-function 'tla-indent-line)
  ;; for writing comments (not fontifying them)
  (setq-local comment-start "(*")
  (setq-local comment-end "*)")
  (electric-indent-local-mode -1)
  (setq-local prettify-symbols-alist tla-symbols-alist)
  (setq-local indent-tabs-mode nil)
  ;; Debugging args fail with starter kit.
  (add-hook 'after-change-functions 'tla-fixcase-keywords t t)
  ;; prettify symbols-mode is not set automatically. See readme
  ;;(prettify-symbols-mode)
  (when (and tla-template-by-default
             (= (point-max) 1))
    (tla-template))

  )



;;;###autoload
(add-to-list 'auto-mode-alist
             '("\\.tla\\'" . tla-mode))

(provide 'tla-mode)

;;; tla-mode.el ends here
