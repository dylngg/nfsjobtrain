# nfsjobtrain

`jobtrain.sh` is a script meant to be run continuously in a cronjob on remote systems connected by a NFS (Network File System) that sequentially executes jobs assigned to it's host. It is meant to be used in scenarios where your only way to communicate with another node is through a NFS. Fundamentally, the script works by executing and **removing** jobs in `jobs/all` and `` jobs/`hostname` `` if a job isn't already running and outputting it to either `out/all` or `` out/`hostname` ``.

## Installation

```bash
$ git clone https://github.com/dylngg/nfsjobtrain.git
$ cd nfsjobtrain
$ # Do the following on all the nodes you want to run on
$ (crontab -l 2>/dev/null; echo "1 * * * * cd `pwd` && /bin/sh jobtrain.sh") | crontab -
$ mkdir -p jobs/`hostame` jobs/all
```

Easy as that.

## Running a job

Copy the executable to the `jobs/host` you want to run on, or `jobs/all`. **The job will be destroyed after it's done.**
