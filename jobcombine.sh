#!/bin/sh
# Combines a job's corresponding outfiles into a single file.
# Usage: ./jobcombine.sh job host1 host2 ...
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  cat <<EOF
jobcombine.sh {JOB} [ARGS] [HOSTS...]

Combines a job's corresponding outfiles into stdout or a single file.

  -h --help		Show this help.

ARGS:
  -d --delim		What to delimit the files by (defaults to \\n).
  -o --out		What file to send the output to (jobname.out if arg not given).
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
  for f in $JOB_OUT_DIR/**/$jobname.out; do
    cat $f >> "$out"
    printf "$delim" >> "$out"
  done

else
  for host in $hosts; do
    cat "$JOB_OUT_DIR/$host/$jobname.out" >> "$out"
    printf "$delim" >> "$out"
  done
fi
