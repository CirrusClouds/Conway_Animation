;;;; sdl-in-lisp.asd

(asdf:defsystem #:sdl-in-lisp
  :description "Describe sdl-in-lisp here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:cl-utils #:raw-bindings-sdl2 #:cffi)
  :components ((:file "package")
               (:file "gol")
               (:file "sdl-in-lisp")))
