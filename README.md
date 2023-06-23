The Blind Hen 2023 ICFP Contest submission
==========================================

Team
----

Jonas B. Jensen
Christoffer R. Nielsen
Johan S. H. Rosenkilde
Kasper Svendsen

All in Copenhagen, Denmark

How to build
------------

First install the "opam" package manager and configure it as follows:

    $ sudo apt-get install opam
    $ opam init # Answer `y` at the prompt
    $ opam switch create 5.0.0
    follow instructions after previous command if run

Install packages we need:

    $ opam install core dune

Now build and run this program:

    $ make
    $ make -j$NUM_CPUS solutions
    $ make solutions.zip

On subsequent terminal sessions, do the following unless you allowed `opam init`
to modify your shell rc:

    $ eval `opam config env`

How to develop
--------------

For vim/emacs support, start with

    $ opam install merlin

Now follow the instructions printed to stdout to configure vim or emacs support.

For VS Code support, install the OCaml Language Server with

    $ opam install ocaml-lsp-server

Now install the VSCode OCaml platform extension

Core library documentation can be found at
https://ocaml.org/p/core/latest/doc/Core/index.html
