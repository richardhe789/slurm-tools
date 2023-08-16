# Steps to run RStudio on a Slurm worker node

## MobaXterm
Use MobaXterm to login/ssh to the master/login node.
Enable the X11-Forwarding

## Request a worker node
This command requests 2 cpu and 2 x 100G=200G memory
```
$ srun --pty -x11 --nodes=1 --ntasks-per-node=2 --mem-per-cpu=100G bash
```
This command proves that 2 cpu and 200G memory are allocated.
```
$ scontrol show job 152 | grep AllocTRES
    AllocTRES=cpu=2,mem=200G,node=1,billing=2
```

If you  want to use all CPU and memory on a worker node, use this command
```
$ srun --pty -x11 --nodes=1 --exclusive bash
```

## Start RStudio
```
$  module load R/4.3.1 RStudio/23.3.0
$  rstudio &
```
Then you can run your R code in the RStudio desktop on the Slurm worker node.

## Note
Recommend using the RStudio interactive session to test R code with small amount of data, it it works, then use ***sbatch*** to submit/run R script in the batch mode with the real data.
