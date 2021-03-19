#!/bin/bash
#SBATCH -J debug
#SBATCH -p debug
#SBATCH -N 1
#SBATCH -o ./1.out
#SBATCH -e ./2.err
#SBATCH --no-requeue
#SBATCH --ntasks-per-node=24
#SBATCH --exclusive

hosts=`scontrol show hostname $SLURM_JOB_NODELIST` ; echo $hosts
