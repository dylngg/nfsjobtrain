#!/bin/sh
# Removes a job and it's corresponding outfile in the specified hosts.
# Usage: ./jobremove.sh job host1 host2 ...
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  cat <<EOF
jobremove.sh {JOB} [ARGS] [HOSTS...]

Removes a job and it's corresponding outfile in the specified hosts.

  -h --help		Show this help.

ARGS:
  -o --out		Remove only the outfile, not the job.
  -j --job		Remove only the job, not the outfile.
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

removeout=true
removejob=true
hasall=false
hosts=""
while test $# -gt 0; do
  case "$1" in
    -o)
      removejob=false
      ;;
    --out)
      removejob=false
      ;;
    -j)
      removeout=false
      ;;
    --job)
      removeout=false
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

if [ "$hosts" == "" ]; then
  die "No host specified"
fi

if $removeout && $hasall; then
  # Remove all the out files at once
  rm -v $JOB_OUT_DIR/*/$jobname.out 2>/dev/null
  removeout=false  # Prevent removal again
fi

for host in $hosts; do
  if $removeout; then
    rm -v "$JOB_OUT_DIR/$host/$jobname.out" 2>/dev/null
  fi
  if $removejob; then
    rm -v "$JOB_DIR/$host/$jobname" 2>/dev/null
  fi
done
