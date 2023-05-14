#!/usr/bin/env bash
#region Constants

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

#endregion
#region Environment Variables with Defaults

LOG_LEVEL="${LOG_LEVEL:-2}"

#endregion
#region Functions

logError() {
  if [[ $LOG_LEVEL -ge ${LOG_LEVELS[Error]} ]]; then
    echo -e "${C_RED}ERROR:${C_RESET} $1"
  fi
}

logWarn() {
  if [[ $LOG_LEVEL -ge ${LOG_LEVELS[Warn]} ]]; then
    echo -e "${C_YELLOW}WARN:${C_RESET} $1"
  fi
}

logInfo() {
  if [[ $LOG_LEVEL -ge ${LOG_LEVELS[Info]} ]]; then
    echo -e "${C_CYAN}INFO:${C_RESET} $1"
  fi
}

logDebug() {
  if [[ $LOG_LEVEL -ge ${LOG_LEVELS[Debug]} ]]; then
    echo -e "${C_BLUE}DEBUG:${C_RESET} $1"
  fi
}

installDependencyIfNotFound() {
  commandName=$1
  packageName=${2:-${commandName}}

  if command -v $commandName &>/dev/null; then
    logInfo "Command found: $commandName"
    return 0
  fi

  logWarn "Missing command, install apt dependency: cmd=$commandName, package=$packageName"
  sudo apt install $packageName
}

#endregion
