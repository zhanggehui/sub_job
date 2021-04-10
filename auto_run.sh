code=$1
NodeNum=$3
scriptsdir=$4
export runscript=$5
export rundir=$6
subdir='/home/liufeng_pkuhpc/lustre2/zgh/sub_job'

# 提交任务前预处理
if [ ${code} == 'gmx' ]; then
    echo "A gromacs job!"
    export scriptsdir
elif [ ${code} == 'lmp' ]; then
    echo "A lammps job!"
elif [ ${code} == 'g4' ]; then
    echo "A Geant4 job!"
    macfile='run.mac'
    initfile='init.mac'
elif [ ${code} == 'test' ];then
    echo "A simple test!"
else
    code=Unknown
    echo "Unknown code! Maybe be some misspelling!"
fi

# 选择使用的节点，指定或者自动选择
echo "---------------- Choosing node! ----------------"
if [ $2 == 'auto' ]; then
    ncnnl=`sinfo | grep 'idle[^\*]' | grep 'cn_nl' | awk '{print $4}'`
    ncns=`sinfo | grep 'idle[^\*]' | grep 'cn-short' | awk '{print $4}'`
    if [ -z "$ncnnl" ] && [ -z "$ncns" ]; then # -n是否为非空串,-z是否为空串,判断必须加引号
        NodeType=cn_nl
    elif [ -z "$ncnnl" ] && [ -n "$ncns" ]; then
        NodeType=cn-short
    elif [ -n "$ncnnl" ] && [ -z "$ncns" ]; then
        NodeType=cn_nl
    else
        if [ $ncnnl -ge 10 ]; then
            NodeType=cn_nl
        elif [ $NodeNum -le $ncnnl ]; then
            NodeType=cn_nl
        elif [ $ncns -gt $ncnnl ]; then
            NodeType=cn-short
        else
            NodeType=cn_nl
        fi
    fi
elif [ $2 == 'cn-short' ]; then
    NodeType=cn-short
elif [ $2 == 'cn_nl' ]; then
    NodeType=cn_nl
elif [ $2 == 'debug' ]; then
    NodeType=debug
else
    NodeType=Unknown
    echo "Unknown NodeType! Maybe be some misspelling!"
fi
echo "--------- Choose ${NodeType} to run this job! ---------"

if [ ! -d $rundir ]; then
    if [ $NodeType == 'Unknown' ] || [ ${code} == 'Unknown' ]; then
        echo "Do nothing!"
    else
        mkdir $rundir
        if [ $NodeType == 'debug' ]; then
            NtasksPerNode=24 #虽然不用于修改提交脚本，但是G4运行时需要更改线程数
            cat $subdir/debug.sh $subdir/${code}.sh > $subdir/debug_${code}.sh
            submissionscript="$subdir/debug_${code}.sh" 
        else
            cat $subdir/cn.sh $subdir/${code}.sh > $subdir/cn_${code}.sh
            if [ $NodeType == 'cn_nl' ]; then
                NtasksPerNode=28
            elif [ $NodeType == 'cn-short' ]; then
                NtasksPerNode=20
            fi
            submissionscript="$subdir/cn_${code}.sh"

            # 修改提交脚本细节
            keyword="#SBATCH -p"; newline="#SBATCH -p $NodeType"
            sed -i "/$keyword/c$newline" $submissionscript
            keyword="#SBATCH -N"; newline="#SBATCH -N $NodeNum"
            sed -i "/$keyword/c$newline" $submissionscript
            keyword="#SBATCH --ntasks-per-node"; newline="#SBATCH --ntasks-per-node=$NtasksPerNode"
            sed -i "/$keyword/c$newline" $submissionscript
            if [ "$NodeType" == cn-short ]; then
                keyword="#SBATCH --qos"; newline="#SBATCH --qos=liufengcns"
                sed -i "/$keyword/c$newline" $submissionscript
            elif [ "$NodeType" == cn_nl ]; then
                keyword="#SBATCH --qos"; newline="#SBATCH --qos=liufengcnnl"
                sed -i "/$keyword/c$newline" $submissionscript
            elif [ "$NodeType" == cn-long ]; then
                keyword="#SBATCH --qos"; newline="#SBATCH --qos=liufengcnl"
                sed -i "/$keyword/c$newline" $submissionscript
            fi
            ##################
        fi
        jobname="${code}_${rundir}" ; keyword="#SBATCH -J" ; newline="#SBATCH -J $jobname"
        sed -i "/$keyword/c$newline" $submissionscript
        oname="./$rundir/1.out" ; keyword="#SBATCH -o" ; newline="#SBATCH -o $oname"
        sed -i "/$keyword/c$newline" $submissionscript
        ename="./$rundir/2.err" ; keyword="#SBATCH -e" ; newline="#SBATCH -e $ename"
        sed -i "/$keyword/c$newline" $submissionscript

        cp $submissionscript ./$rundir #为了进行事后检查提交脚本
        cp $scriptsdir/$runscript ./$rundir #为了事后检查运行脚本，或者隔离不同情形的模拟运行文件(单独修改)

        # 针对选择不同code的后处理
        if [ ${code} == 'gmx' ]; then
            echo "gromacs post process!"
            if [ $runscript == 'nvt-cycle.sh' ]; then
                cp $scriptsdir/nvt-cycle.mdp ./$rundir
            fi
        elif [ ${code} == 'lmp' ]; then
            echo "lammps post process!"
        elif [ ${code} == 'g4' ]; then
            echo "Geant4 post process!"
            cp $scriptsdir/$macfile ./$rundir
            cp ../$initfile ./$rundir
            str1="numberOfThreads"
            str2="/run/numberOfThreads $NtasksPerNode"
            sed -i "/$str1/c$str2" ./$rundir/$initfile
        elif [ ${code} == 'test' ]; then
            echo "test post process!"
        fi

        sbatch $submissionscript
        rm -rf $submissionscript

        echo "Submiting a job to ${NodeType}, Please wait 2s!"
        sleep 2s
    fi
else
    echo 'Rundir already exists! Please make sure!'
fi
