#!/usr/bin/env bash

. ./common.sh

# check for required tools
packages=( git chsh )
for var in "${packages[@]}"
do
  if ! [ -x "$(command -v ${var})" ]; then
    echo "Error: package ${var} is not installed." >&2
    exit 1
  fi
done

###
###  Set the shell
###

# set login shell to zsh
if [[ "$SHELL" != *zsh ]]; then
  echo "changing login shell to zsh"
  chsh -s $(which zsh)
fi

# Install OMZ and plugins

## Remove the old versions

zshdir="${ZSH:-${HOME}/.oh-my-zsh}"
zshcustom="${ZSH_CUSTOM:-${zshdir}/custom/}"

## Install new versions

name="oh-my-zsh"
get_repo "${name}" "https://github.com/robbyrussell/${name}.git" "${zshdir}"

name="zsh-nvm"
get_repo "${name}" "https://github.com/lukechilds/${name}" "${zshcustom}/plugins/${name}"

name="zsh-autosuggestions"
get_repo "${name}" "https://github.com/zsh-users/${name}" "${zshcustom}/plugins/${name}"

name="zsh-fzy"
get_repo "${name}" "https://github.com/aperezdc/${name}" "${zshcustom}/plugins/${name}"

name="powerlevel9k"
get_repo "${name}" "https://github.com/bhilburn/${name}" "${zshcustom}/themes/${name}"

echo $0 done
