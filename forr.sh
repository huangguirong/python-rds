#!/bin/bash

#慢日志开始时间
stime=`date -d"yesterday" +"%F"`'T16:01Z'
#慢日志结束时间
etime=`date +%F`'T15:59Z'
#页面大小
pagenum=100
#rds实例ID

function get_slows {
  python rds.py $1 $2 $3 $4
}

rds_ids='rm-xxxx1 rm-xxxxx2 rm-xxxxx3'
for rds_id in $rds_ids;do
    count=`get_slows "$stime" "$etime" 1 "$rds_id" |grep TotalRecordCount|awk -F' ' '{print $2}'`
    
    if [ "$count" == "0" ];then
      echo '实例'"$rds_id"'没有慢日志~';continue
    fi
    
    pd=$(echo "scale=1;$count/"$pagenum""|bc)
    xs=$(echo $pd|cut -d'.' -f2)
    #总页数
    zs=$(echo $pd|cut -d'.' -f1)
    if [ ! -n "$zs" ];then
      zs=0
    fi
    if [ "$xs" -gt 0 ];then
      zs=$((zs+1))
    fi
    
    #sql总量
    full_sql=$(echo  `echo $stime|cut -d'T' -f1|sed -r 's#-#_#g'`_`echo $stime|cut -d'T' -f2|cut -d'Z' -f1|sed -r 's#:##g'`_`echo $etime|cut -d'T' -f1|sed -r 's#-#_#g'`_`echo $etime|cut -d'T' -f2|cut -d'Z' -f1|sed -r 's#:##g'`).sql
    
    for i in `seq $zs`;do
      get_slows "$stime" "$etime" "$i" "$rds_id">>/tmp/slow/"$rds_id"$full_sql
    done
    
    #去重后sql
    uniq_sql=uniq_$full_sql
    grep SQLText /tmp/slow/"$full_sql"|sed -r 's#"SQLText": "##g'|sed 's/.$//'|sed 's/^ *//'|sed -r 's#\\n##g' |sed -r 's#\\##g'|sed -r 's#_[0-9]##g'|uniq -c|awk '{$1="";print $0}' >/tmp/slow/"$rds_id""$uniq_sql"
    sed -i 's/$/;/' /tmp/slow/"$rds_id""$uniq_sql"
done
