#lang racket

;; the 9 puzzle pieces, top right bottom left; shape, in/out
(define pieces
  (vector `((c 1) (h 1) (d 0) (c 0))
          `((h 1) (d 1) (c 0) (c 0))
          `((s 1) (d 1) (s 0) (h 0))
          `((s 1) (s 1) (h 0) (c 0))
          `((c 1) (h 1) (s 0) (h 0))
          `((h 1) (d 1) (d 0) (h 0))
          `((h 1) (s 1) (s 0) (c 0))
          `((d 1) (c 1) (c 0) (d 0))
          `((s 1) (d 1) (h 0) (d 0))))

;; puzzle piece structure
(struct puzzle-piece (index flip rotation) #:transparent)

;; given a piece structure, figure out what the piece actually looks like
(define get-edge-configuration
  (λ (piece)
    (rotate (if (= 1 (puzzle-piece-flip piece))
                (flip (vector-ref pieces (puzzle-piece-index piece)))
                (vector-ref pieces (puzzle-piece-index piece)))
            (puzzle-piece-rotation piece))))

;; piece sides
(define top first)
(define right second)
(define bottom third)
(define left fourth)
(define T (compose top get-edge-configuration))
(define R (compose right get-edge-configuration))
(define B (compose bottom get-edge-configuration))
(define L (compose left get-edge-configuration))

;; rotate a piece clockwise by r quarter-turns
;; assumes r \leq length of the piece
(define rotate
  (λ (piece r)
    (append (drop piece (- (length piece) r))
            (take piece (- (length piece) r)))))

;; flips a piece about the x-axis
(define flip
  (λ (piece)
    (list (bottom piece)
          (right piece)
          (top piece)
          (left piece))))

;; all possible ways to place down a piece
(define all-configurations
  (λ (index flips?)
    (map (λ (x)
           (puzzle-piece index (first x) (second x)))
         (if flips?
             '((0 0) (0 1) (0 2) (0 3) (1 0) (1 1) (1 2) (1 3))
             '((0 0) (0 1) (0 2) (0 3))))))

;; 3 4 5
;; 2 1 6
;; 9 8 7

;; given (backwards, partial) list of pieces (index flip rotation) placed in the above configuration
;; and pieces (index) to try adding next
(define extend
  (λ (placed to-try flips?)
    (cond
      [(= (length placed)
          (vector-length pieces))
       (list placed)]
      [(empty? to-try)
       empty]
      [else
       (apply append
              (cons (extend placed
                            (rest to-try)
                            flips?)
                    (map (λ (config)
                           (if (extend-by-one? placed config)
                               (extend (cons config placed)
                                       (unused-indices (build-list (vector-length pieces) identity)
                                                       (cons config placed))
                                       flips?)
                               empty))
                         (all-configurations (first to-try)
                                             flips?))))])))

;; given (backwards, partial) list of pieces (index flip rotation) and piece (index flip rotation)
;; see if it fits
(define extend-by-one?
  (λ (placed potential)
    (match (length placed)
      [0 true]
      [1 (fit? (L (first placed))
               (R potential))]
      [2 (fit? (T (first placed))
               (B potential))]
      [3 (and (fit? (R (first placed))
                    (L potential))
              (fit? (T (third placed))
                    (B potential)))]
      [4 (fit? (R (first placed))
               (L potential))]
      [5 (and (fit? (B (first placed))
                    (T potential))
              (fit? (R (fifth placed))
                    (L potential)))]
      [6 (fit? (B (first placed))
               (T potential))]
      [7 (and (fit? (L (first placed))
                    (R potential))
              (fit? (B (seventh placed))
                    (T potential)))]
      [8 (and (fit? (L (first placed))
                    (R potential))
              (fit? (B (seventh placed))
                    (T potential)))])))

;; which (indices of) pieces haven't been used yet in list of (index flip rotation)
(define unused-indices
  (λ (all-indices used-pieces)
    (if (empty? used-pieces)
        all-indices
        (remove (puzzle-piece-index (first used-pieces))
                (unused-indices all-indices (rest used-pieces))))))

;; do 2 slots fit together?
(define fit?
  (λ (a b)
    (and (not (= (second a)
                 (second b)))
         (symbol=? (first a)
                   (first b)))))

;; the actual function, to find all solutions to the puzzle
;; fix the first piece to avoid the same solution coming up 4 or 8 times due to symmetry
(define find-solutions
  (λ (flips?)
    (apply append
           (map (λ (index)
                  (extend (list (puzzle-piece index 0 0))
                          (remove index
                                  (build-list (vector-length pieces) identity))
                          flips?))
                (build-list (vector-length pieces) identity)))))
