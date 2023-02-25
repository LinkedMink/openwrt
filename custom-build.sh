#!/usr/bin/env bash

# Constants
C_GREEN='\033[0;32m'
C_L_CYAN='\033[1;36m'
C_YELLOW='\033[1;33m'
C_RESET='\033[0m'

# Option Defaults
LOG_LEVEL="1" # 1-99, s, sc
LOG_FILE="build.log"
THREADS=$(($(nproc) - 2))
CLEAN=

# Functions
logInfo() {
  echo -e "${C_L_CYAN}INFO:${C_RESET} $1"
}

logWarn() {
  echo -e "${C_YELLOW}WARN:${C_RESET} $1"
}

installDependency() {
  if command -v $1 &>/dev/null; then
    logInfo "Command found: $1"
    return 0
  fi

  logWarn "Missing command, install apt dependency: cmd=$1, package=$2"
  sudo apt install $2
}

installDependency unbuffer expect

# Parse Args
VALID_ARGS=$(getopt -o l:o:t:c: --long log:,output:,threads:,clean: -- "$@")
if [[ $? -ne 0 ]]; then
  exit 1
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
  -l | --log)
    LOG_LEVEL=$2
    shift 2
    ;;
  -o | --output)
    LOG_FILE=$2
    shift 2
    ;;
  -t | --threads)
    THREADS=$2
    shift 2
    ;;
  -c | --clean)
    CLEAN=$2
    shift 2
    ;;
  --)
    shift
    break
    ;;
  esac
done

# Pre-Build Clean
if [ "$CLEAN" = f ]; then
  logInfo "Pre-build - Full cleaning"
  make clean
elif [ "$CLEAN" = p ]; then
  logInfo "Pre-build - Clean kernel targets only"
  make target/linux/clean
  make package/boot/uboot-mediatek/clean
else
  logInfo "Pre-build - No cleaning performed, f=full, p=partial"
fi

rm $LOG_FILE

# Build
logInfo "---------- START - ${C_YELLOW}Running build with params: LOG_LEVEL=${LOG_LEVEL} LOG_FILE=${LOG_FILE} THREADS=${THREADS}${C_RESET} ----------"

time unbuffer \
  make -j $THREADS V=$LOG_LEVEL |
  tee $LOG_FILE

logInfo "---------- END  - ${C_GREEN}Success${C_RESET}  ----------"
