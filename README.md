# nfsjobtrain

`jobtrain.sh` is a script meant to be run continuously in a cronjob on remote systems connected by a NFS (Network File System) that sequentially executes jobs assigned to it's host. It is meant to be used in scenarios where your only way to communicate with another node is through a NFS. Fundamentally, the script works by executing jobs in `jobs/all` and `` jobs/`hostname` `` that are not already running and don't have a output file. Upon execution, the output is created in either `out/all` or `` out/`hostname` ``, depending on which job folder the job was found in.

## Installation

```bash
$ git clone https://github.com/dylngg/nfsjobtrain.git
$ cd nfsjobtrain
$ # Do the following on all the nodes you want to run on (may have to modify "`pwd`")
$ (crontab -l 2>/dev/null; echo "* * * * * cd `pwd`; /bin/sh jobtrain.sh") | crontab -
$ mkdir -p jobs/`hostame` jobs/all
```

Easy as that.

## Running a job

Copy/move the executable to the `jobs/host` you want to run on, or `jobs/all`. Your cronjob on each host should execute that program.

A script called `jobsubmit.sh` can help facilitate this:

```bash
$ jobsubmit.sh --help
jobsubmit.sh {JOB} [HOSTS...]

Submits jobs to the jobtrain. If the job host directory doesn't exist, it is
created.

  -h --help		Show this help.
```
