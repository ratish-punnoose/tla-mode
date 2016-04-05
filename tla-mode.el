;;; tla-mode.el --- TLA+ language support for Emacs

;; Copyright (C) 2015-2016 Ratish Punnoose

;; Author: Ratish Punnoose
;; Version: 1.0
;; URL: https://github.com/ratish-punnoose/tla-mode
;; Created: 8 Jun 2015

;;; Code:

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

(defvar tla-tab-width 2 "Width of a tab")

(defvar tla-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?_ "w" st)

    (modify-syntax-entry ?\( ". 1" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\) ". 4" st)
    
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


;;;###autoload
(define-derived-mode tla-mode prog-mode "TLA"
  "TLA mode is a major mode for writing TLA+ specifications"
  :syntax-table tla-mode-syntax-table
  
  (setq-local font-lock-defaults tla-font-lock-defaults)
  
  ;; for writing comments (not fontifying them)
  (setq-local comment-start "(*")
  (setq-local comment-end "*)")

  (setq-local prettify-symbols-alist
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
                ("LAMBDA" . ?λ)
                ))


  (prettify-symbols-mode)  
  )

;;;###autoload
(add-to-list 'auto-mode-alist
             '("\\.tla\\'" . tla-mode))

(provide 'tla-mode)

;;; tla-mode.el ends here
