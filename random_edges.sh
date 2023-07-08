#!/bin/zsh
# A script that returns a random subset of north,east,west,south

directions=(north east west south)
# Select a random number of edges
how_many=$((RANDOM % 5))
# Select a random subset of directions
# Remove trailing , and newline
shuf -e "${directions[@]}" | head -n $how_many | tr '\n' ',' | sed 's/,$//'
