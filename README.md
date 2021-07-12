# 参数含义: 
code; NodeType; NodeNum; scriptsdir; runscript; rundir

# 集群更新该仓库
cd /home/liufeng_pkuhpc/lustre2/zgh/sub_job ; gitget ; cd $OLDPWD

# 简单的test
source /home/liufeng_pkuhpc/lustre2/zgh/sub_job/auto_run.sh \
test debug 1 /home/liufeng_pkuhpc/lustre2/zgh/sub_job/ test.sh test
第4和第5个参数仅为了补足参数
