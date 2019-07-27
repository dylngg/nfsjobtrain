#!/bin/sh
# Executes a job if something isn't running and there is one available. Meant
# to be run on a interval in a cronjob.
# ---
# Made by Dylan Gardner
# ---

# job and out dir can be controlled with JOB_DIR and JOB_OUT_DIR
default_job_dir="jobs"
if [ "$JOB_DIR" == "" ]; then JOB_DIR="$default_job_dir"; fi
default_job_all_dir="$JOB_DIR/all"
if [ "$JOB_ALL_DIR" == "" ]; then JOB_ALL_DIR="$default_job_all_dir"; fi
default_job_out_dir="out"
if [ "$JOB_OUT_DIR" == "" ]; then JOB_OUT_DIR="$default_job_out_dir"; fi

found_jobs=`find "$JOB_DIR/\`hostname\`" "$JOB_ALL_DIR" -type f 2>/dev/null`
if [ "$?" -ne 0 ]; then
    exit 1
fi

# Want a job that doesn't have a out file
for job in $found_jobs; do
  jobname=`basename "$job"`
  outpath="$JOB_OUT_DIR/`hostname`/$jobname.out"
  if [ ! -f "$outpath" ]; then
    chosen_job="$job"
    break
  fi
done

if [ "$chosen_job" == "" ]; then
  # We didn't find any jobs
  exit 0
fi

# Make the out directory if it doesn't exist
outdir=`dirname $outpath`
if [ ! -d "$outdir" ]; then
  mkdir -p "$outdir"
fi

self=`id -u`
is_job_running=`ps -u "$self" -o comm | grep -v "| grep" | grep "$jobname"`
# Must be a valid job and cannot be running
if [ "$is_job_running" == "" ]; then
  ./"$chosen_job" > "$outpath" &
fi
