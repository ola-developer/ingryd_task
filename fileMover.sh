#!/bin/bash

mkdir -p "$HOME/backUps"

mv "$1" "$HOME/backUps"

mv "$2" "$HOME/backUps"

echo "$HOME/backUps"
