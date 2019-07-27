#!/bin/sh
# Submits jobs to the jobtrain. If the job host directory doesn't exist, it is
# created.
# Usage: ./jobsubmit job host1 host2 ...
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  cat <<EOF
jobsubmit.sh {JOB} [HOSTS...]

Submits jobs to the jobtrain. If the job host directory doesn't exist, it is
created.

  -h --help		Show this help.
EOF
  exit 0
fi

job="$1"
shift

die() {
  echo "$1"
  exit 1
}

if [ ! -f "$job" ]; then
  die "No such file"
fi

# Make sure jobtrain.sh can execute the job
if IFS= read -r line < "$job"; then
  case $line in
    ("#!"*)
      # pass
      ;;
    *)
      die "Shebang (#!/bin/bash) is not present"
      ;;
  esac
fi

default_job_dir="jobs"
if [ "$JOB_DIR" == "" ]; then JOB_DIR="$default_job_dir"; fi

for host in "$@"; do
  host_job_dir="$JOB_DIR/$host"
  if [ -f "$host_job_dir" ]; then
    die "Job host directory: $host_job_dir is a file, not a directory"
  elif [ ! -d "$host_job_dir" ]; then
    mkdir -p "$host_job_dir"
  fi
  cp "$job" "$host_job_dir"
done

if [ "$host_job_dir" == "" ]; then
  die "No host specified"
fi

echo "Done."
