;;; moonscript.el --- Major mode for editing MoonScript code -*- lexical-binding: t -*-
;;
;; Author: @Janfel, @GriffinSchneider, @k2052, @EmacsFodder
;; Version: 20140803-0.1.0
;; Package-Requires: ((emacs "24"))
;;
;;; Commentary:
;;
;; A basic major mode for editing MoonScript, a preprocessed language
;; for Lua which shares many similarities with CoffeeScript.
;;
;;; License: MIT Licence
;;
;;; Code:

(defgroup moonscript nil
  "MoonScript (for Lua) language support for Emacs."
  :tag "MoonScript"
  :group 'languages)

(defcustom moonscript-indent-offset 2
  "How many spaces to indent MoonScript code per level of nesting."
  :group 'moonscript
  :type 'integer
  :safe 'integerp)

(defcustom moonscript-comment-start "-- "
  "Default value of `comment-start'."
  :group 'moonscript
  :type 'string
  :safe 'stringp)

(defcustom moonscript-interactive-indent-commands
  '(indent-for-tab-command)
  "Which commands should cycle indentation."
  :group 'moonscript
  :type '(repeat symbol)
  :safe 'listp)

(defvar moonscript-keywords
  '("for" "while"
    ;; Conditionals
    "if" "else" "elseif" "then" "switch" "when" "unless"
    ;; Statements.
    "return" "break" "continue"
    ;; Regular keywords.
    "export" "local" "import" "from" "with" "in" "and"
    "or" "not" "class" "extends" "super" "using" "do"))

(defvar moonscript-constants         '("nil" "true" "false" "self"))
(defvar moonscript-function-keywords '("->" "=>" "(" ")" "[" "]" "{" "}"))

(defvar moonscript-assignment-regex     "\\([-+/*%]\\|\\.\\.\\)?=")
(defvar moonscript-assignment-var-regex "\\(\\_<\\w+\\) = ")
(defvar moonscript-class-name-regex     "\\<[A-Z]\\w*\\>")
(defvar moonscript-constants-regex      (regexp-opt moonscript-constants 'symbols))
(defvar moonscript-function-regex       (regexp-opt moonscript-function-keywords))
(defvar moonscript-ivar-regex           "@\\_<\\w+\\_>")
(defvar moonscript-keywords-regex       (regexp-opt moonscript-keywords 'symbols))
(defvar moonscript-number-regex         "[0-9]+\\.[0-9]*\\|[0-9]*\\.[0-9]+\\|[0-9]+")
(defvar moonscript-octal-number-regex   "\\_<0x[[:xdigit:]]+\\_>")
(defvar moonscript-table-key-regex      "\\_<\\w+:")
(defvar moonscript-font-lock-defaults
  `((,moonscript-assignment-regex     . font-lock-preprocessor-face)
    (,moonscript-assignment-var-regex . (1 font-lock-variable-name-face))
    (,moonscript-class-name-regex     . font-lock-type-face)
    (,moonscript-constants-regex      . font-lock-constant-face)
    (,moonscript-function-regex       . font-lock-function-name-face)
    (,moonscript-ivar-regex           . font-lock-variable-name-face)
    (,moonscript-keywords-regex       . font-lock-keyword-face)
    (,moonscript-number-regex         . font-lock-constant-face)
    (,moonscript-octal-number-regex   . font-lock-constant-face)
    (,moonscript-table-key-regex      . font-lock-variable-name-face)
    ("!"                              . font-lock-warning-face)))

(defun moonscript--calculate-indent ()
  "Calculate a sensible default indentation level."
  (let ((oldindent (floor (current-indentation) moonscript-indent-offset))
        (prevlineindent
         (floor (save-excursion (forward-line -1) (current-indentation))
                moonscript-indent-offset)))
    (if (and (zerop oldindent) (not (zerop prevlineindent)))
        prevlineindent
      oldindent)))

(defun moonscript--calculate-indent-interactive ()
  "Calculate an indentation level for use with the TAB key."
  (let ((oldindent (floor (current-indentation) moonscript-indent-offset))
         (prevlineindent
          (save-excursion
            (beginning-of-line)
            (skip-chars-backward " \t\r\n")
            (if (eq (point) (point-min)) 0
              (floor (current-indentation) moonscript-indent-offset)))))
    (cond ((eq oldindent prevlineindent) (1+ prevlineindent))
          ((not (eq last-command this-command)) (max prevlineindent 1))
          ;; These clauses only activate on repeated calls.
          ((eq oldindent (1+ prevlineindent)) 0)
          (t (1+ oldindent)))))

(defun moonscript-indent-line ()
  "Cycle indentation levels for the current line of MoonScript code.

Looks at how deeply the previous non-blank line is nested. The
maximum indentation level for the current line is that level plus
one."
  (let ((indent
         (if (memq this-command moonscript-interactive-indent-commands)
             (moonscript--calculate-indent-interactive)
           (moonscript--calculate-indent)))
        (inside-indent
         (<= (- (point) (line-beginning-position)) (current-indentation))))
    (save-excursion
      (beginning-of-line)
      (skip-chars-forward " \t")
      (delete-region (line-beginning-position) (point))
      (indent-to (* indent moonscript-indent-offset)))
    (when inside-indent (back-to-indentation))))

;;;###autoload
(define-derived-mode moonscript-mode prog-mode "MoonScript"
  "Major mode for editing MoonScript code."
  (setq font-lock-defaults '(moonscript-font-lock-defaults))
  (setq-local indent-line-function 'moonscript-indent-line)
  (setq-local electric-indent-inhibit t)
  (setq-local comment-start moonscript-comment-start)
  (modify-syntax-entry ?\- ". 12b" moonscript-mode-syntax-table)
  (modify-syntax-entry ?\n "> b"   moonscript-mode-syntax-table)
  (modify-syntax-entry ?\_ "w"     moonscript-mode-syntax-table))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.moon\\'" . moonscript-mode))

(provide 'moonscript)

;;; moonscript.el ends here
