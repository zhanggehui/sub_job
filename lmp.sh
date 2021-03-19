# environment variable:
# rundir ; runscript

export OMP_NUM_THREADS=1
source /home/liufeng_pkuhpc/lustre2/zgh/lmp/lmp_use/lammps_29Oct2020.sh auto
cd ./$rundir
mpirun -np $SLURM_NTASKS lmp -e screen -log none -in ${runscript##*/}
