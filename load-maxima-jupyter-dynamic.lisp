(require :asdf)
#+sbcl (require :sb-rotate-byte)

;; activate debugging
; (declaim (optimize (speed 0) (space 0) (debug 3) (safety 3)))

;; Load user code from "./user-pre-hook.lisp" and "./user-pre-hook.mac" if they exist.
;; These may be used to load quicklisp.
(eval-when (:compile-toplevel :load-toplevel :execute) ; load quicklisp before lisp sees the package "ql" below.
  (let* ((user-pre-hook-base
          (list :directory  (pathname-directory *load-truename*)
                :device (pathname-device *load-truename*)
                :name  "user-pre-hook")))
    (dolist (suffix '("lisp" "mac"))
      (let ((user-pre-hook-file (apply #'make-pathname (append user-pre-hook-base (list :type suffix)))))
        (if (probe-file user-pre-hook-file)
            (if (eq suffix "lisp")
                (load user-pre-hook-file)
              (maxima::$load user-pre-hook-file)))))))

;; We need quicklisp to find the asd file in the sub-directory "src" of this directory.
;; We follow the advice on the web page below to use ql:*local-project-directories*.
;; "Use Quicklisp to load personal projects from arbitrary locations."
;; https://www.darkchestnut.com/2016/quicklisp-load-personal-projects-from-arbitrary-locations/
(let ((this-dir-list (pathname-directory *load-truename*))) ; get components of this directory
  (push "src" (cdr (last this-dir-list)))  ; put subdirectory "src" at the end of the list of components
  (let ((src-dir
         (make-pathname :directory this-dir-list
                        :device (pathname-device *load-truename*))))
    (pushnew src-dir ql:*local-project-directories*)))

(format t "ql:*local-project-directories* =~S~%" ql:*local-project-directories*)
(ql:register-local-projects)

(maxima::$load "stringproc")
(ql:quickload "maxima-jupyter")
