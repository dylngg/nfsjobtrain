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

found_jobs=`find "$JOB_DIR/\`hostname\`" "$JOB_ALL_DIR" -type f`
if [ "$?" -ne 0 ]; then
    exit 1
fi

chosen_job=`echo $found_jobs | head -n 1`
jobname=`basename "$chosen_job"`
case $chosen_job in
  $JOB_ALL_DIR*)
    outpath="$JOB_OUT_DIR/all/$jobname.out"
    ;;
  *)
    outpath="$JOB_OUT_DIR/`hostname`/$jobname.out"
    ;;
esac

# Make the out directory if it doesn't exist
outdir=`dirname $outpath`
if [ ! -d "$outdir" ]; then
  mkdir -p "$outdir"
fi

self=`id -u`
is_job_running=`ps -u "$self" -o comm | grep -v "grep" | grep "$jobname"`
# Must be a valid job and cannot be running
if [ "$chosen_job" != "" ] && [ "$is_job_running" == "" ]; then
  ./"$chosen_job" > "$outpath"; rm "$chosen_job" &
fi
