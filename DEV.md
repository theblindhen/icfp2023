## How to develop

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
