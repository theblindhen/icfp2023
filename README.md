The Blind Hen 2023 ICFP Contest submission
==========================================

Team
----

Jonas B. Jensen,
Christoffer R. Nielsen,
Johan S. H. Rosenkilde, and
Kasper Svendsen

All in Copenhagen, Denmark

How to build
------------

First install the "opam" package manager and configure it as follows:

    # apt-get install opam
    $ opam init # Answer `y` at the prompt
    $ opam switch create 5.0.0
    follow instructions after previous command if run

Install packages we need:

    $ opam install core core_unix atdgen yojson dune

Now go into the right subdirectory and build and run one of these commands:

    $ dune build
    $ dune test
    $ dune exec PROG_NAME

On subsequent terminal sessions, do the following unless you allowed `opam init`
to modify your shell rc:

    $ eval `opam config env`

How to develop
--------------

### GUI support

To compile the GUI portion of our code, run

    $ opam install bogue

The GUI is run from the OCaml project subdirectory by running

    $ dune exec gui [OPTIONS]

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

We use the GUI library Bogue, which has a good introductory guide at
http://sanette.github.io/bogue/Principles.html
and API documentation at
https://ocaml.org/p/bogue/latest/doc/Bogue/index.html
