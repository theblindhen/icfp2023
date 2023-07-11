The Blind Hen 2023 ICFP Contest submission
==========================================

Team
----

Jonas B. Jensen,
Christoffer R. Nielsen,
Johan S. H. Rosenkilde, and
Kasper Svendsen

All in Copenhagen, Denmark

Strategy
--------

We had a selection of ways to initialize a solution and another selection of
ways to improve a solution.

A solution could be initialized by:
* Randomly placing musicians on the stage.
* Placing a row of musicians along one or more edges, then placing the rest
  randomly.
* Various arrangements that tried to maximise or minimise visibility.
* Loading the best solution from a previous run.
* Interpreting the score contributions of audience members as forces, then
  moving musicians stepwise by those forces. In the first phase, all musicians
  of the same instrument were collapsed into one point, and those points could
  overlap. In the second phase, the instruments were separated into individual
  musicians, and they were not allowed to overlap.

The initial solution could then be improved by chaining _optimizers_ together in
a sequence:
* We could swap pairs of musicians, performing all advantageous swaps until
  there was no way to increase the score by swapping a pair of musicians.
  It was very fast (constant time) to determine whether a swap was good by
  caching all the "hearability" data that remained valid as long as no
  musicians moved.

How to build
------------

First install the "opam" package manager and configure it as follows:

    # apt-get install opam
    $ opam init # Answer `y` at the prompt
    $ opam switch create 5.0.0
    follow instructions after previous command if run

Install packages we need:

    $ opam install core core_unix atdgen yojson dune lp-glpk opium

Now go into the right subdirectory and build and run one of these commands:

    $ dune build
    $ dune test
    $ dune exec PROG_NAME

On subsequent terminal sessions, do the following unless you allowed `opam init`
to modify your shell rc:

    $ eval `opam config env`

How to develop
--------------

### Copilot in VSCode

Intall the Microsoft-built version of VSCode, not the open-source ones. Then
install GitHub Copilot from the market place and sign in to your GitHub account
when it prompts you. Also install GitHub Copilot Chat.

### IDE

For OCaml IDE support, start with

    $ opam install merlin ocaml-lsp-server ocamlformat

For vim or emacs support, follow the instructions printed to stdout.

For VSCode support, install OCaml Platform from the VSCode Marketplace. Open the
workspace `icfp2023.code-workspace` in this directory to ensure we all use the
same settings (format on save!).

### Documentation

Core library documentation can be found at
https://ocaml.org/p/core/latest/doc/Core/index.html
