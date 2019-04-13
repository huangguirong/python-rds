# python-rds


#脚本执行步骤：
改forr.sh脚本中的
#慢日志开始时间 注（阿里的控制台上查的慢日志时间和命令查的时候相差8小时），那么以下设置的时候则是当天的00:00到当天的23:59
stime=`date -d"yesterday" +"%F"`'T16:01Z'
#慢日志结束时间
etime=`date +%F`'T15:59Z'

rds_ids是实例id
####

sh forr.sh
