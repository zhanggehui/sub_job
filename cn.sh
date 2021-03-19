#!/bin/bash
#SBATCH -J code
#SBATCH -p cn_nl
#SBATCH -N 1
#SBATCH -o ./1.out
#SBATCH -e ./2.err
#SBATCH --no-requeue
#SBATCH -A liufeng_g1
#SBATCH --qos=liufengcnnl
#SBATCH --ntasks-per-node=28
#SBATCH --exclusive

hosts=`scontrol show hostname $SLURM_JOB_NODELIST` ; echo $hosts
