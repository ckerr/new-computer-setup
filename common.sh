#!/usr/bin/env bash

if [ 'x' != "x$(command -v gsed)" ]; then
  declare -r gsed='gsed'
else
  declare -r gsed='sed'
fi

if [ 'x' != "x$(command -v gfind)" ]; then
  declare -r gfind='gfind'
else
  declare -r gfind='find'
fi

if [ 'x' != "x$(command -v ginstall)" ]; then
  declare -r ginstall='ginstall'
else
  declare -r ginstall='install'
fi

###
###  Helpers
###

# Modify variables in a file.
# Doesn't assume much since syntaxes vary e.g. between .zshrc and .vimrc
function set_variable_in_file {
  local -r filename="${1}"
  local -r search="${2}"
  local -r var="${3}"

  # if there's a line starting with $search, replace it
  local -r count=$(grep --count "^${search}" "${filename}")
  if [ "x${count}" = 'x1' ]; then
    "${gsed}" --in-place='' "s/^${search}.*/${var}/" "${filename}"
    return
  fi

  # if there's a line starting with "# $search", insert our version there
  if [ "x$(grep --count "^# ${search}" "${filename}")" = 'x1' ]; then
    "${gsed}" --in-place='' "/^# ${key}.*/a \\${var}" "${filename}"
    return
  fi

  # not found at all; just add it to the end
  echo "${var}" >> "${filename}"
}

function set_variable_in_shell_script {
  local -r filename="${1}"
  local -r key="${2}"
  local -r val="${3}"

  set_variable_in_file "${filename}" "${key}=" "${key}=\"${val}\""
}

# https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
function is_repo_current() {
  local -r path="${1}"
  local -r repo_url="${2}"

  env git -C "${path}" remote update &> /dev/null
  if [ ! -d "${path}" ]; then
    return 1
  fi

  local -r LOCAL=$(env git -C "${path}" rev-parse @)
  local -r REMOTE=$(env git -C "${path}" rev-parse @{u})
  [ "x${LOCAL}" = "x${REMOTE}" ]
}

function get_repo() {
  local -r parent_dir="${1}"
  local -r repo_url="${2}"
  if (( $# > 2 )); then
    local -r name="${3}"
  else
    local tmp="${repo_url}"
    tmp="${tmp##*/}" # basename
    local -r name="${tmp%%.*}" # strip suffix
    unset tmp
  fi

  echo getting $repo_url

  local -r path="${parent_dir}/${name}"
  if is_repo_current "${path}" "${repo_url}"; then
    return 0
  fi

  if [ -d "${path}" ]; then
    env git -C "${path}" pull --stat --rebase --prune
  else
    # ensure parent directory exists
    if [ ! -d "${parent_dir}" ]; then
      mkdir -p "${parent_dir}"
      chmod 750 "${parent_dir}"
    fi
    env git clone -q "${repo_url}" "${path}"
    chmod 750 "${path}"
  fi
  env git -C "${path}" submodule update --init --recursive
}

