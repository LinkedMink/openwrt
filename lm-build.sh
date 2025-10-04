#!/usr/bin/env bash
# Full Reset: ./lm-build.sh -c build -r -d

source lm-utility.sh

#region Option Defaults

logLevelBuild="1" # 1-99, s, sc
logFileBuild="build.log"
threadCount=$(($(nproc) - $(nproc) / 4))
cleanTargets=
isPredownloaded=false
isConfigReset=false
isCompilationErrorsIgnored=false

#endregion
#region Parse Args

usage() {
  echo "Usage: $0 [options]"
  echo "  -l <1-99|s|sc> logLevelBuild"
  echo "  -o <filename> logFileBuild"
  echo "  -t <integer> threadCount"
  echo "  -c <kernel|package|target|build> cleanTargets"
  echo "  -d isPredownloaded"
  echo "  -r isConfigReset"
  echo "  -i isCompilationErrorsIgnored"
  exit 1
}

option=
while getopts l:o:t:c:dri option; do
  case "$option" in
  l)
    logLevelBuild=$OPTARG
    ;;
  o)
    logFileBuild=$OPTARG
    ;;
  t)
    threadCount=$OPTARG
    if ! [[ "$threadCount" =~ ^[0-9]+$ ]]; then
      echo "Invalid Argument: -t number"
      usage
    fi
    ;;
  c)
    cleanTargets=$OPTARG
    if ! [[ "$cleanTargets" =~ ^(kernel|package|target|build)$ ]]; then
      echo "Invalid Argument: -c kernel|package|target|build"
      usage
    fi
    ;;
  d)
    isPredownloaded=true
    ;;
  r)
    isConfigReset=true
    ;;
  i)
    isCompilationErrorsIgnored=true
    ;;
  *)
    echo "Invalid Argument: $option"
    usage
    ;;
  esac
done
shift $((OPTIND-1))

logDebug "$(cat <<EOT
Options:
  logLevelBuild=$logLevelBuild
  logFileBuild=$logFileBuild
  threadCount=$threadCount
  cleanTargets=$cleanTargets
  isPredownloaded=$isPredownloaded
  isConfigReset=$isConfigReset
  isCompilationErrorsIgnored=$isCompilationErrorsIgnored
EOT
)"

#endregion
#region Pre-Build Clean and Preparation

# https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem#cleaning_up
if [ "$cleanTargets" = kernel ]; then
  logInfo "Pre-build - Clean kernel targets only"
  make target/linux/clean
  make package/boot/uboot-mediatek/clean
  for makeTarget in package/kernel/*; do
    make "package/kernel/$makeTarget/clean"
  done
elif [ "$cleanTargets" = package ]; then
  logInfo "Pre-build - Clean all architecture packages"
  make clean
elif [ "$cleanTargets" = target ]; then
  logInfo "Pre-build - Clean all architecture specific targets"
  make targetclean
elif [ "$cleanTargets" = build ]; then
  logInfo "Pre-build - Clean all local tools and architecture targets"
  make dirclean
else
  logDebug "Pre-build - Clean not performed kernel|package|target|build"
fi

if [ "$isConfigReset" = true ]; then
  ./lm-reset-filogic-config.sh
fi

if [ "$isPredownloaded" = true ]; then
  make download
fi

if [ "$isCompilationErrorsIgnored" = true ]; then
  export IGNORE_ERRORS=1
fi

rm -f "$logFileBuild"

#endregion
#region Build

logInfo "---------- Build START ----------"
logInfo "Running build with params: -l ${C_YELLOW}${logLevelBuild}${C_RESET} -o ${C_YELLOW}${logFileBuild}${C_RESET} -t ${C_YELLOW}${threadCount}${C_RESET}"

time unbuffer \
  make -j "$threadCount" V="$logLevelBuild" |
  tee "$logFileBuild"

logSuccess "---------- Build -END- ----------"

#endregion
