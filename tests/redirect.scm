;;;; redirect.scm -- tests for (mcron redirect) module
;;; Copyright © 2020 Mathieu Lirzin <mthl@gnu.org>
;;;
;;; This file is part of GNU Mcron.
;;;
;;; GNU Mcron is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; GNU Mcron is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Mcron.  If not, see <http://www.gnu.org/licenses/>.

(use-modules (ice-9 textual-ports)
             (srfi srfi-1)
             (srfi srfi-64)
             (mcron redirect))

(setenv "TZ" "UTC0")

(test-begin "redirect")

(define out (mkstemp! (string-copy "foo-XXXXXX")))

(dynamic-wind
  (const #t)
  (lambda ()
    (with-mail-out "echo 'foo'" "user0"
                   #:out (lambda () out)
                   #:hostname "localhost")

    (flush-all-ports)

    (test-equal "mail output"
      "To: user0
From: mcron
Subject: user0@localhost

foo
"
      (call-with-input-file (port-filename out) get-string-all)))

  (lambda ()
    (let ((fname (port-filename out)))
      (close out)
      (delete-file fname))))

(test-end)
