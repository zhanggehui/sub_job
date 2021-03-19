# environment variable:

# orientation; rundir; runscript; scriptsdir

# export I_MPI_DEBUG=20
if [ $SLURM_JOB_PARTITION == 'cn_nl' ]; then
    echo 'Choose gromacs2019.2_intelmkl2019u4 ( for cn_nl ) !' 
    source /appsnew/mdapps/gromacs2019.2_intelmkl2019u4/bin/GMXRC2.bash
else
    # 2020的环境变量，但是有没装mdrun_mpi
    # export LD_LIBRARY_PATH=/appsnew/usr/gcc/gcc-7.4.0/lib64:$LD_LIBRARY_PATH
    # source /appsnew/source/intel2019.sh
    # source /appsnew/mdapps/gromacs2020_cpu_intelmkl2019_cnscompat/bin/GMXRC.bash
    echo 'Choose gromacs2019.3_cpu_intelmkl2019_cnscompat ( for cn-short ) !' 
    source /appsnew/mdapps/gromacs2019.3_cpu_intelmkl2019_cnscompat/bin/GMXRC2.bash
fi

if [ $SLURM_JOB_NUM_NODES -eq 1 -a $Usempirun -eq 0 ]; then
    gmxrun="gmx mdrun -ntmpi $SLURM_NTASKS"
else
    #mpistring="mpirun -n $SLURM_NTASKS -quiet --mca pml ob1 --mca btl_openib_allow_ib true"
    mpistring="mpirun -n $SLURM_NTASKS"
    gmxrun="$mpistring mdrun_mpi"
    #gmxrun="$mpistring mdrun_mpi2"
fi

source ./$rundir/$runscript
