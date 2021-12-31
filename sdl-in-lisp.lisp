;;;; sdl-in-lisp.lisp

(in-package #:sdl-in-lisp)

(defparameter SCREEN_WIDTH 1040)
(defparameter SCREEN_HEIGHT 720)
(defparameter CELL_WIDTH (floor (/ SCREEN_WIDTH NO_OF_CELLS)))
(defparameter CELL_HEIGHT (floor (/ SCREEN_HEIGHT NO_OF_CELLS)))

(defun main ()
  (if (< (sdl:sdl-init sdl:+sdl-init-everything+) 0)
      (error "Initialisation failed")
      (let* ((window (sdl:sdl-create-window "Game of Life"
                                            sdl:+sdl-windowpos-undefined+
                                            sdl:+sdl-windowpos-undefined+
                                            SCREEN_WIDTH SCREEN_HEIGHT
                                            sdl:+sdl-window-shown+))
             (screen-surface (sdl:sdl-get-window-surface window))
             (white-block (sdl:sdl-load-bmp "S.bmp"))
             (black-block (sdl:sdl-load-bmp "black.bmp")))
        (if (cffi:null-pointer-p window)
            (error "Window couldn't be created")
            (if (or (cffi:null-pointer-p black-block) (cffi:null-pointer-p white-block))
                (error "Can't load image")
                (progn
                  (render-board *board* window white-block black-block screen-surface)
                  (gol-loop window white-block black-block screen-surface)
                  (sdl:sdl-destroy-window window)
                  (sdl:sdl-quit)
                  0))))))

(defun gol-loop (win wb bb screen)
  (let ((running-p t)
        (b *board*))
    (loop
      :while running-p
      :do
         (cffi:with-foreign-object (e 'sdl:sdl-event)
           (loop :while (not (equal 0 (sdl:sdl-poll-event e)))
                 :do
                    (cffi:with-foreign-slots ((sdl:type) e (:union sdl:sdl-event))
                      (cond ((equal sdl:type 771)
                             (setf running-p nil)))))
           (setf b (next b))
           (render-board b win wb bb screen)
           (sdl:sdl-update-window-surface win)
           (sdl:sdl-delay 10)
           ))))


(defun render-board (b win wb bb screen)
  (loop :for i :in (cl-utils:range (- NO_OF_CELLS 1))
        :do
           (loop :for j :in (cl-utils:range (- NO_OF_CELLS 1))
                 :do
                    (let ((cell (aref b i j)))
                      (if (equal cell 'Alive)
                          (render-cell i j wb screen)
                          (render-cell i j bb screen))))))

(defun render-cell (i j rec screen)
  (cffi:with-foreign-object (scr 'sdl:sdl-rect)
    (setf
     (cffi:foreign-slot-value scr 'sdl:sdl-rect 'sdl:x) (* i CELL_WIDTH)
     (cffi:foreign-slot-value scr 'sdl:sdl-rect 'sdl:y) (* j CELL_WIDTH)
     (cffi:foreign-slot-value scr 'sdl:sdl-rect 'sdl:w) SCREEN_WIDTH
     (cffi:foreign-slot-value scr 'sdl:sdl-rect 'sdl:h) SCREEN_HEIGHT)
    (cffi:with-foreign-object (r 'sdl:sdl-rect)
      (setf
       (cffi:foreign-slot-value r 'sdl:sdl-rect 'sdl:x) 0
       (cffi:foreign-slot-value r 'sdl:sdl-rect 'sdl:y) 0
       (cffi:foreign-slot-value r 'sdl:sdl-rect 'sdl:w) CELL_WIDTH
       (cffi:foreign-slot-value r 'sdl:sdl-rect 'sdl:h) CELL_HEIGHT)
      (cffi:with-foreign-slots ((sdl:x sdl:y sdl:w sdl:h) r 'sdl:sdl-rect)
        (sdl:sdl-blit-surface rec
                              r
                              screen
                              scr)))))
