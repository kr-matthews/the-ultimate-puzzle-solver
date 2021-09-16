# "The Ultimate Puzzle" Solver

A simple back-tracking program built in Racket to find all solutions to ["The Ultimate Puzzle"](https://theultimatepuzzle.com/).
You can allow or disallow flipping pieces over from their natural face-up orientation.

Note that the version I solved is slightly different than the one linked above and only has 9 pieces instead of 16.
I did originally solved the one linked above several years prior to this one (also in Racket), but the code was neither organized nor commented so I haven't made it public.

### Run

The easiest way to run the code is use an online Racket compiler such as [OneCompiler](https://onecompiler.com/racket/). Copy the code from puzzle.rkt and paste it there. Alternatively, clone the repository to your computer and open it with [DrRacket](https://download.racket-lang.org/).

As it is, there are only definitions, no expressions to evaluate, so no output/results will appear. To actually generate the solution(s), run "(find-solutions false)" to find all solutions with the pieces face up, or "(find-solutions true)" to find all solutions (face up or face down).

The answer is a list of puzzle pieces, indicating the index, face up or face down, and how to rotate it on the surface. Use puzzle-pieces-picture.png to look-up a physical piece from the index. The list starts with the center piece, then the piece to the left, and from there it circles clockwise:

3 4 5
2 1 6
9 8 7
