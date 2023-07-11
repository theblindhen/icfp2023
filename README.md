# The Blind Hen 2023 ICFP Contest submission

## Team

Jonas B. Jensen,
Christoffer R. Nielsen,
Johan S. H. Rosenkilde, and
Kasper Svendsen

All in Copenhagen, Denmark

We used OCaml this year, and Elm client + OCaml server for visualization.

dwdw## Strategy

We had a selection of ways to initialize a solution and another selection of
ways to improve a solution, described below. In practice, most of our score came
from using Edges with Swap or LP for placing musicians on the positions, though
most everything we did contributed some points.

A solution could be initialized by:

- Random: Randomly placing musicians on the stage.
- Edges: Placing a row of musicians along one or more edges, then placing the rest
  randomly.
- Load: Loading the best solution from a previous run.
- Newtonian physics: We use audience member tastes as forces, pushing or pulling
  musicians. This had three stages: 1. One point per musician, with no repelling
  forces between them; 2. Explode the instruments into individual musicians,
  introducing forces to repel musicians from each other to minimize overlap. 3.
  Remove audience member forces, keeping only the repelling forces to get to a
  legal state.
- Various arrangements that tried to maximise or minimise visibility. None of
  these were successful.

The initial solution could then be improved by chaining _optimizers_ together in
a sequence:

- Swap: Swapping pairs of musicians, performing all advantageous swaps until
  there was no way to increase the score by swapping a pair of musicians.
  It was very fast (constant time) to determine whether a swap was good by
  caching all the "hearability" data that remained valid as long as no
  musicians moved.

- LP: Optimal swapping based on linear programming. Ignoring the q-factors,
  assigning musicians to a fixed set of positions is formulated as linear
  programming and solved optimal. This was too slow on large maps, so later we
  improved it to randomly select a subset of positions and solve this optimally,
  then iterating this a number of times.

- Newtonian physics: Like stages 2 and 3 of the initialization strategy, but
  with weaker forces, to optimize placements.

- Drop: Take all musicians whose score contributes less than 10% of the
  highest musician's score and randomly place them on the stage.

As usual, plumbing is a big part of ICFPC. We had e.g.

- a Git-based system and scripts for maintaining best solutions;
- scripts for running our solver on multi-core VMs on Azure;
- Visualization using an Elm client and OCaml server.

## Storyline

### 0-24h: Lightning round

For lightning round, we implemented Random and Edges initialization, and Swap
and LP optimizations. Our best position was around 16th place.

As usual, we were quite unprepared and none of us had written much OCaml for a
long time. We realized 2 hours before the contest that OCaml 5.0 wouldn't run on
Windows which one team member used, and we had no spare Linux machine. We tried
WSL, VMWare and VirtualBox but they ended up unsatisfactory.

Visulization was another pain point. We had expected to use the Bogue library
built on SDL. After sinking a few hours into a rudimentary visualisation, we
realized it rendered completely borked on Mac, which another team member used.

### 24-48h: The long haul

During Saturday, we didn't have much visible progress, and fell down the high
score, but made good preparatory work for the remaining contest:

- Implementing support for the q-factor and pillar extensions.

- Our Windows team member got set up with a GitHub Codespaces, which worked
  quite well.

- We scratched the fledgling Bogue GUI and rewrote it as an OCaml server + Elm
  client. This was a big success and allowed all four members to run the GUI.

- We designed the radial sweep scoring function and sunk a good few hours into
  implementing it. However, timing showed slightly disappointing improvement in
  practice, and we couldn't get it to produce the exact same scores. In the end
  we shelved it.

- We began implementing Newtonian physics, and had the first signs of
  life Saturday evening.

- Worked on improving the LP implementation. A big laugh here was when we
  got a factor x100 speedup in setting up the system by swapping the operands of
  an add operation (exposing a poor algorithm in the underlying library).

### 48h-72h: The final sprint

In the last 24 hours we finished up the open tasks from yesterday, while trying
out many other ideas. Disappointment gradually increased as each of our ideas
revealed to bring only marginal improvements. Nevertheless, we slowly crawled
a bit higher on the scoreboard.

We also had to work a bit on plumbing towards the end, e.g. improving our
command-line parsing to select and compose our growing number of strategies, and
extending our GUI to visualize where our solutions could be improved.

We also looked at statistics on the problems to try to figure out where our
efforts were best spent. The problems had widely different scoring potential,
and using some heuristics we could estimate a maximal score for each. In many
problems we couldn't see how to improve the score beyond placing musicians at
the edge, especially after the last update to the problem (where poor musicians
could simply be turned off). We tried various heuristics for spacing them to
allow musicians behind to be visible, but none of these worked well.

The Newtonian physics turned out to be problematic to mature. It contained many
magic constants that had to be carefully balanced to each other, and it was hard
to ensure that it ended up in a legal state. We also never got to integrate any
of our ideas for integrating line-of-sight, and this completely cripples the
algorithm's efficacy on the problem.

Another improvement came from integrating q-scoring into the swap algorithm.
This was complicated because we tried to limit the computational cost of
recomputing the q-scores. We got a rough version finished that gave good
improvements, while a more polished version never got finished.

## How to build

first install the "opam" package manager and configure it as follows:

    # apt-get install opam
    $ opam init # answer `y` at the prompt
    $ opam switch create 5.0.0
    follow instructions after previous command if run

install packages we need:

    $ opam install core core_unix atdgen yojson dune lp-glpk opium

now go into the right subdirectory and build and run one of these commands:

    $ dune build
    $ dune test
    $ dune exec prog_name

on subsequent terminal sessions, do the following unless you allowed `opam init`
to modify your shell rc:

    $ eval `opam config env`
