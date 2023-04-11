#!/usr/bin/env bash

# Constants
C_RED='\033[1;31m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[1;34m'
C_CYAN='\033[1;36m'
C_RESET='\033[0m'

declare -A LOG_LEVELS
LOG_LEVELS[Error]=0
LOG_LEVELS[Warn]=1
LOG_LEVELS[Info]=2
LOG_LEVELS[Debug]=3

# Environment Variables
LOG_LEVEL="${LOG_LEVEL:-2}"

# Functions
logError() {
  if [[ $LOG_LEVEL -ge ${LOG_LEVELS[Error]} ]]; then
    echo -e "${C_RED}ERROR:${C_RESET} $1"
  fi
}

logWarn() {
  if [[ $LOG_LEVEL -ge ${LOG_LEVELS[Warn]} ]]; then
    echo -e "${C_YELLOW}WARN:${C_RESET}  $1"
  fi
}

logInfo() {
  if [[ $LOG_LEVEL -ge ${LOG_LEVELS[Info]} ]]; then
    echo -e "${C_CYAN}INFO:${C_RESET}  $1"
  fi
}

logDebug() {
  if [[ $LOG_LEVEL -ge ${LOG_LEVELS[Debug]} ]]; then
    echo -e "${C_BLUE}DEBUG:${C_RESET} $1"
  fi
}

installDependencyIfNotFound() {
  if command -v $1 &>/dev/null; then
    logInfo "Command found: $1"
    return 0
  fi

  logWarn "Missing command, install apt dependency: cmd=$1, package=$2"
  sudo apt install $2
}
