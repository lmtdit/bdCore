#!/bin/sh
#启动gulp

#!/bin/bash

export PATH=/usr/local/bin:/bin:/usr/bin
export NODE_PATH=/usr/local/lib/node_modules

gulp dev

checknode(){
	#获取node pid
	nodepid=$(ps -e | grep node | awk '{print $1}');
	echo $nodepid
	#如果node进程id为空,则重新启动node
	if [ -z $nodepid ];
	then
		echo 'node is restart';
		gulp watch 
	fi
}

#开启定时检测
while true;do
	eval "checknode";
	sleep 5 
	continue	
done