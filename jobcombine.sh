#!/bin/bash
# Combines a job's corresponding outfiles into a single file.
# Usage: ./jobcombine.sh job host1 host2 ...
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  cat <<EOF
jobcombine.sh {JOB} [ARGS] [HOSTS...]

Combines a job's corresponding outfiles into stdout or a single file.

  -h --help             Show this help.

ARGS:
  -d CHAR, --delim      CHAR What to delimit the files by (defaults to \\n).
  -o FILE, --out FILE   What file to send the output to (jobname.out if FILE
                        not given, otherwise stdout)
  -v, --verbose         Prints out the hosts that didn't have a outfile.
  -w TIME, --wait TIME  Waits the given time, or until all the outfiles appear
                        before combining the outfiles into a single file.
EOF
  exit 0
fi

die() {
  echo "$1"
  exit 1
}

job="$1"
if [ "$1" == "" ]; then
  die "No job given"
fi
jobname=`basename $job`
shift

default_job_dir="jobs"
if [ "$JOB_DIR" == "" ]; then JOB_DIR="$default_job_dir"; fi
default_job_out_dir="out"
if [ "$JOB_OUT_DIR" == "" ]; then JOB_OUT_DIR="$default_job_out_dir"; fi

verbose=false
timeout=0
out="/dev/stdout"
delim='\n'
hasall=false
hosts=""
while test $# -gt 0; do
  case "$1" in
    -d | --delim)
      delim="$2"
      shift
      ;;
    -o | --out)
      if [ "$2" != "" ]; then
        out="$2"
      else
        out="$jobname.out"
      fi
      shift
      ;;
    -v | --verbose)
      verbose=true
      ;;
    -w | --wait)
      timeout="$2"
      shift
      ;;
    --*) echo "bad option $1"
      ;;
    *)
      if [ "$1" == "all" ]; then hasall=true; fi
      hosts+="$1 "
      ;;
  esac
  shift
done
# Remove trailing space
hosts=`echo $hosts | xargs`

if [ "$hosts" == "" ]; then
  hosts="all"
  hasall=true
fi

if $hasall; then
  hosts=`find $JOB_OUT_DIR/ -maxdepth 1 -mindepth 1 -type d -exec basename '{}' \; | tr '\n' ' '`
fi

downhosts=($hosts)
uphosts=()
starttime=`date +%s`
endtime=`expr $starttime + $timeout`
while (( "`date +%s`" <= "$endtime" )); do
  for host in ${downhosts[@]}; do
    if [ -f "$JOB_OUT_DIR/$host/$jobname.out" ]; then
      downhosts=("${downhosts[@]:1}")
      uphosts+=("$host")
    fi
  done

  if [ ${#downhosts[@]} -eq 0 ]; then
    break
  fi
  sleep 0.2
done

for host in ${uphosts[@]}; do
  echo $host >> "$out"
  cat "$JOB_OUT_DIR/$host/$jobname.out" >> "$out"
  printf "$delim" >> "$out"
done

if $verbose; then
  printf "No outfiles found for: "
  for host in ${downhosts[@]}; do
    printf "$host "
  done
  echo ""
fi
