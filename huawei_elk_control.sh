#!/bin/bash
clear
echo -e "\033[44;37m       <<<< This is Huawei ELK Telemetry Control Script>>>>       \033[0m"
echo ">>>>>>>>>>>>> Press Ctrl+C to cancel, Any key to continue" 

#This script must be root to run
read -n 1
[ $(id -u) != "0" ] && echo -e "ERROR: You must be root to run this script" && exit 1

ELK_FILES_DIR="/usr/elkfiles"
ELK_INSTALL_DIR="/usr/elk"
RUBY_PROTOC_DIR="/usr/soft"
SUCCESS_CODE=0
FAIL_CODE=1
LOGSTASH_CODEC_DIR="logstash-5.5.0/local-plugins/logstash-codec-telemetry-gpb/logstash-codec-telemetry-gpb"
LOGSTASH_INPUT_DIR="logstash-5.5.0/local-plugins/logstash-input-unix-hw/logstash-input-unix-hw"

PLUGIN_CODEC_NAME="logstash-codec-bigmuddy-network-telemetry-gpb-master"
PLUGIN_INPUT_NAME="logstash-input-unix-master"

INI_VALUE=""


check_env() {
	# check sigle enviroment	
	local OPTIND
	while getopts 'e:r:h:c:t:s:' OPT; do
		case $OPT in
			e) 
				local env_name="$OPTARG";;
			r) 
				local right_res="$OPTARG";;
			h) 
				local hint="$OPTARG";;
			c) 
				local cmd_res="$OPTARG";;
			t)
				local type="$OPTARG";;
			s)
				local need_show="$OPTARG";;
			?)
				echo "Wrong Params: check_env"
		esac
	done
	
	if [ $type == 'string' ]
	then
		if [[ "$cmd_res" =~ "$right_res" ]]
		then 
			return $SUCCESS_CODE
		else 
			if [ $need_show == 'yes' ]
			then
				echo -e "\033[31m ERROR: The server dosn't install ${hint} ! \033[0m"
			fi
			return $FAIL_CODE
		fi
	fi
	
	if [ $type == 'number' ]
	then	
		if (( "$cmd_res" >= "$right_res" ))
		then 
			return $SUCCESS_CODE
		else 
			if [ $need_show == 'yes' ]
			then
				echo -e "\033[31m ERROR: The server dosn't install ${hint} ! \033[0m"
			fi
			return $FAIL_CODE
		fi
	fi

}

check_elk_env() {

	# check enviroment which elk depend on
	c1=$(which gcc) 	
	check_env -e "gcc" -r "/gcc" -h "gcc" -c "$c1" -t "string" -s "yes"
	e1=$(echo $?)	
	
	c2=$(ruby -v|awk -F '.' '{print $2}') 
	check_env -e "ruby" -r 3 -h "ruby(version>=2.3)" -c "$c2" -t "number" -s "yes"
	e2=$(echo $?) 
	
	
	c4=$(python3 -V) 
	check_env -e "python3" -r "Python 3.5" -h "python(version=3.5.x)" -c "$c4" -t "string" -s "no"
	e4_1=$(echo $?)
	
	check_env -e "python3" -r "Python 3.6" -h "python(version=3.6.x)" -c "$c4" -t "string" -s "no"
	e4_2=$(echo $?)
	
	if [[ $(($e4_1*$e4_2)) == $FAIL_CODE ]]
	then
		echo -e "\033[31m ERROR: The server dosn't install python3.5/python3.6 ! \033[0m"
	fi
	
	c5=`echo $(java -version 2>&1 |awk 'NR==1'| awk -F '.' '{print $2}')`
	check_env -e "java" -r 8 -h "java(version >= 8)"  -c  "$c5" -t "number" -s "yes"
	e5=$(echo $?)	
	
	c6=`echo $(find /usr/ -name zlib.pc 2>&1 | awk 'NR==1')`
	check_env -e "zlib" -r "zlib.pc" -h "zlib" -c "$c6" -t "string" -s "yes"
	e6=$(echo $?)
	
	c7=$(pip3 --version|grep '^pip')
	check_env -e "pip3" -r "pip" -h 'python3-pip' -c "$c7" -t "string" -s "yes"
	e7=$(echo $?)
	
	local res_code=$(($e1+$e2+$e3+$e4_1*$e4_2+$e5+$e6+$e7))
	if [ $res_code == $SUCCESS_CODE ]
	then
		echo -e "\n"
		echo -e "\033[42;37m =================== The Environment is ok ==================== \033[0m"
		echo -e "\n"
		return $SUCCESS_CODE
	else 
		return $FAIL_CODE
	fi
}

check_file() {
	file_name=$1
	if [ ! -d "$ELK_FILES_DIR" ]
	then
		echo -e "\033[33m !! Please put the files under $ELK_FILES_DIR !! \033[0m"	
		return $FAIL_CODE
	fi
	cd $ELK_FILES_DIR
	if [ ! -f "$file_name" ]
	then
		echo -e "\033[31m Error : \033[0m"
		printf "%-15s %-45s %-66s\n" "The file " "$file_name" "hasn't been downloaded, Please downLoad it and put it under $ELK_FILES_DIR !!"
		return $FAIL_CODE
	else
		return $SUCCESS_CODE
	fi
}	

check_elk_files() {
	# what is prepare for ruby-protocol-buffers-1.6.1.gem
	check_file "glibc-2.14.tar.gz"  
	f1=$(echo $?)	
	check_file "protoc-2.6.1.gem" 
	f2=$(echo $?)	
	check_file "Platform-0.4.2.gem" 
	f3=$(echo $?)	
	check_file "ruby-protocol-buffers-1.6.1.gem" 
	f4=$(echo $?)
	check_file "elasticsearch-5.5.0.tar.gz" 
	f5=$(echo $?)
	check_file "kibana-5.5.0-linux-x86_64.tar.gz" 
	f6=$(echo $?)
	check_file "logstash-5.5.0.tar.gz" 
	f7=$(echo $?)
	check_file "grpcio-1.4.0-cp35-cp35m-manylinux1_x86_64.whl" 
	f8_1=$(echo $?)
	check_file "grpcio-1.4.0-cp36-cp36m-manylinux1_x86_64.whl" 
	f8_2=$(echo $?)	
	check_file "six-1.10.0-py2.py3-none-any.whl" 
	f9=$(echo $?)
	check_file "protobuf-3.3.0.tar.gz" 
	f10=$(echo $?)
	
	# what is prepare for logstash plugins
	check_file "logstash-codec-bigmuddy-network-telemetry-gpb-master.zip" 
	f11=$(echo $?)
	check_file "logstash-input-unix-master.zip" 
	f12=$(echo $?)
	check_file "HuaweiDialGrpc.tar.gz" 
	f13=$(echo $?)
	check_file "logstashplugin.patch" 
	f14=$(echo $?)
	
	local res_code=$(($f1+$f2+$f3+$f4+$f5+$f6+$f7+$f8_1*$f8_2+$f9+$f10+$f11+$f12+$f13+$f14))
	
	if [ $res_code == $SUCCESS_CODE ]
	then
		echo -e "\n"
		echo -e "\033[42;37m =================== The files are ok =================== \033[0m"
		echo -e "\n"
		return $SUCCESS_CODE
	else 
		return $FAIL_CODE
	fi
}

check_repeat_es_conf(){
	# check the elasticsearch configuration is already exited , else if add configuration
	exit1=$(grep -Pzo "\* soft nofile 65536\s*\* hard nofile 131072\s*\* soft nGproc 65536\s*\* hard nproc 65536\s*\*  - as unlimited" /etc/security/limits.conf)
	if [ -z "$exit1" ] 
	then
		return $SUCCESS_CODE
	else
		return $FAIL_CODE
	fi
}

install_elasticsearch() {
	rm -r "$ELK_INSTALL_DIR"/elasticsearch-5.5.0
	# firstly verify the file has already put the configuration	 
	check_repeat_es_conf
	local check_res=$(echo $?)
	if [ $check_res == $SUCCESS_CODE ]
	then
		# if has not configured ,we need to add configuration for elasticsearch
		cat >> /etc/security/limits.conf <<EOF
* soft nofile 65536 
* hard nofile 131072 
* soft nGproc 65536 
* hard nproc 65536
*  - as unlimited
EOF
	fi 

	tar -zxvf "$ELK_FILES_DIR"/elasticsearch-5.5.0.tar.gz -C "$ELK_INSTALL_DIR"
	groupadd elkgroup
	useradd elkuser -g elkgroup
	mkdir /home/elkuser
	chown -R elkuser:elkgroup "$ELK_INSTALL_DIR"
	echo "vm.max_map_count = 655360" >>/etc/sysctl.conf && sysctl -p
cat >>"$ELK_INSTALL_DIR"/elasticsearch-5.5.0/config/elasticsearch.yml<<EOF
network.host: ${e_ip}
http.port: ${e_port}
bootstrap.system_call_filter: false
EOF
}

install_kibana() {
	rm -r "$ELK_INSTALL_DIR"/kibana-5.5.0-linux-x86_64
	tar -zxvf "$ELK_FILES_DIR"/kibana-5.5.0-linux-x86_64.tar.gz -C "$ELK_INSTALL_DIR"
	cat >> "$ELK_INSTALL_DIR"/kibana-5.5.0-linux-x86_64/config/kibana.yml <<EOF
server.port: "${k_port}"
server.host: "${k_ip}"
elasticsearch.url: "http://${e_ip}:${e_port}"
EOF
}

install_logstash() {
	rm -r "$ELK_INSTALL_DIR"/logstash-5.5.0
	# decompression logstash
	tar -zxvf "$ELK_FILES_DIR"/logstash-5.5.0.tar.gz -C "$ELK_INSTALL_DIR"	
	# --------->>>>>>>> now under logstash installation directory
	#prepare for patch sync
	cd "$ELK_INSTALL_DIR"/logstash-5.5.0/
	mkdir -p "$ELK_INSTALL_DIR"/"$LOGSTASH_CODEC_DIR"
	mkdir -p "$ELK_INSTALL_DIR"/"$LOGSTASH_INPUT_DIR"
	mkdir -p "$ELK_INSTALL_DIR"/logstash-5.5.0/huawei-test/protos/
	touch "$ELK_INSTALL_DIR"/logstash-5.5.0/huawei-test/unix_test.conf
	# prepare logstash plugin from open sources
	# sync codec plugin files
	# plugin for codec
	rm -r "$ELK_FILES_DIR"/"$PLUGIN_CODEC_NAME"  "$ELK_FILES_DIR"/"$PLUGIN_INPUT_NAME"
	cd "$ELK_FILES_DIR"
	unzip "$ELK_FILES_DIR"/"$PLUGIN_CODEC_NAME".zip
	unzip "$ELK_FILES_DIR"/"$PLUGIN_INPUT_NAME".zip
	mv "$ELK_FILES_DIR"/"$PLUGIN_CODEC_NAME"/* "$ELK_INSTALL_DIR"/"$LOGSTASH_CODEC_DIR"	
	cd "$ELK_INSTALL_DIR"/"$LOGSTASH_CODEC_DIR"
	mv lib/logstash/codecs/telemetry_gpb.rb lib/logstash/codecs/telemetry_gpb_hw.rb
	mv logstash-codec-telemetry-gpb.gemspec logstash-codec-hw-telemetry-gpb.gemspec	
	
	#### plugin for input 
	mv "$ELK_FILES_DIR"/"$PLUGIN_INPUT_NAME"/* -t "$ELK_INSTALL_DIR"/"$LOGSTASH_INPUT_DIR"
	cd "$ELK_INSTALL_DIR"/"$LOGSTASH_INPUT_DIR"
	mv lib/logstash/inputs/unix.rb lib/logstash/inputs/unix_hw.rb
	mv logstash-input-unix.gemspec logstash-input-unix-hw.gemspec
	cd "$ELK_INSTALL_DIR"/
	### patch start
	cp "$ELK_FILES_DIR"/logstashplugin.patch "$ELK_INSTALL_DIR"/
	patch -p3 < "$ELK_INSTALL_DIR"/logstashplugin.patch
	
	## prepare for start up and run 
	env GEM_HOME=vendor/bundle/jruby/1.9 
	cp "$ELK_FILES_DIR"/ruby-protocol-buffers-1.6.1.gem "$ELK_INSTALL_DIR"/logstash-5.5.0/
	gem install ruby-protocol-buffers-1.6.1.gem -l	
	cp "$ELK_FILES_DIR"/*.proto "$ELK_INSTALL_DIR"/logstash-5.5.0/huawei-test/protos/
	cp "$ELK_FILES_DIR"/*.pb.rb "$ELK_INSTALL_DIR"/logstash-5.5.0/huawei-test/protos/
	cd "$ELK_INSTALL_DIR"/logstash-5.5.0/huawei-test/
	touch UNIX.d && touch gpb_decode.log && touch "$ELK_INSTALL_DIR"/logstash-5.5.0/nohup.out
	## configure ip & port
	sed -i "s/127\.0\.0\.1\:9200/$e_ip\:$e_port/g" "$ELK_INSTALL_DIR"/logstash-5.5.0/huawei-test/unix_test.conf
}

install_ruby_protoc() {

	if [ ! -d "$ELK_INSTALL_DIR" ] 
	then
		echo -e "\033[33m !! Now creating ruby-protoc install dir !! \033[0m"	
		mkdir -p "$ELK_INSTALL_DIR"
	fi

	version=$(strings /lib64/libc.so.6 |grep GLIBC)
	result=$(echo ${version} | grep "GLIBC_2.14")
		if [ -z "$result" ]
		then
			tar -zxvf "$ELK_FILES_DIR"/glibc-2.14.tar.gz -C "$RUBY_PROTOC_DIR"
			tar -zxvf "$ELK_FILES_DIR"/glibc-ports-2.14.tar.gz -C "$RUBY_PROTOC_DIR"
			mv "$ELK_FILES_DIR"/glibc-ports-2.14 "$RUBY_PROTOC_DIR"/glibc-2.14/ports
			mkdir -p "$RUBY_PROTOC_DIR"/glibc-2.14/build
			cd "$RUBY_PROTOC_DIR"/glibc-2.14/build
			../configure  --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin
			make
			make install
		fi
	gem install "$ELK_FILES_DIR"/Platform-0.4.2.gem -l
	gem install "$ELK_FILES_DIR"/protoc-2.6.1.gem -l
	gem install "$ELK_FILES_DIR"/ruby-protocol-buffers-1.6.1.gem -l
}

install_python_grpc(){
	pip3 install "$ELK_FILES_DIR"/six-1.10.0-py2.py3-none-any.whl
	tar -zxvf "$ELK_FILES_DIR"/protobuf-3.3.0.tar.gz -C "$ELK_INSTALL_DIR"/
	cd "$ELK_INSTALL_DIR"/protobuf-3.3.0/
	python3 setup.py build
	python3 setup.py install
	cd "$ELK_INSTALL_DIR"
	
	c4=$(python3 -V) 
	check_env -e "python3" -r "Python 3.5" -h "python(version=3.5.x)" -c "$c4" -t "string" -s "no"
	e4_1=$(echo $?)
	
	if [ $e4_1 == $SUCCESS_CODE ]
	then
		pip3 install "$ELK_FILES_DIR"/grpcio-1.4.0-cp35-cp35m-manylinux1_x86_64.whl
	else
		pip3 install "$ELK_FILES_DIR"/grpcio-1.4.0-cp36-cp36m-manylinux1_x86_64.whl	
	fi
	
	tar -zxvf "$ELK_FILES_DIR"/HuaweiDialGrpc.tar.gz -C "$ELK_INSTALL_DIR"/	
}

install_elk_softwares() {
	# begin install
	echo -e "\033[33m >>> start install ES \033[0m"
	install_elasticsearch 
	es_install_res=$(echo $?)
	echo -e "\033[33m >>> start install Kibana \033[0m"
	install_kibana 
	ki_install_res=$(echo $?)
	echo -e "\033[33m >>> start install Logstash \033[0m"
	install_logstash 
	logstash_install_res=$(echo $?)
	echo -e "\033[33m >>> start install ruby protoc \033[0m"
	install_ruby_protoc 
	rubyprotoc_install_res=$(echo $?)
	echo -e "\033[33m >>> start install python grpc \033[0m"
	install_python_grpc 
	grpc_install_res=$(echo $?)
	
	local install_res=$(($es_install_res+$ki_install_res+$logstash_install_res+$rubyprotoc_install_res+$grpc_install_res))
	echo "===============================> install: $es_install_res===$ki_install_res=== $logstash_install_res === $rubyprotoc_install_res === $grpc_install_res "
	echo -e "\n"
	if [ $install_res == $SUCCESS_CODE ]
	then
		echo -e "\033[42;37m          CONGRATULATIONS! ELK INSTALL SUCCESS!          \033[0m"
	else 
		echo -e "\033[41;37m          SORRY! ELK INSTALLATION FAILED!          \033[0m"
	fi
	echo -e "\n"
}

check_process_with_port() {
	# check count of params ,if count = 1,then not check port
	if [ $# == 3 ] ; then
		#check process with ip and port,if open ,return 0; else return 1
		port=$1
		program=$2	
		tohint=$3
		check_port=`netstat -lntup|grep ${port}|wc -l`
		check_program=`ps -ef|grep ${program}|grep -v grep|wc -l`
		
			if [ $check_port -gt 0 ] || [ $check_program -gt 0 ]
			then
				if [ $tohint == "need_hint" ]
				then
					echo -e "\033[32m ${program}:${port} is running! \033[0m" 
				fi
				return $SUCCESS_CODE
			else
				if [ $tohint == "need_hint" ]
				then
					echo -e "\033[31m ${program}:${port} is not running! \033[0m" 
				fi
				return $FAIL_CODE
			fi		
	elif [ $# == 2 ] ; then
		program=$1
		tohint=$2
		check_program=`ps -ef|grep ${program}|grep -v grep|wc -l`
		
			if [ $check_program -gt 0 ]
			then
				if [ $tohint == "need_hint" ]
				then
					echo -e "\033[32m ${program} is running! \033[0m" 
				fi
				return $SUCCESS_CODE
			else
				if [ $tohint == "need_hint" ]
				then
					echo -e "\033[31m ${program} is not running! \033[0m" 
				fi
				return $FAIL_CODE
			fi
	else
		echo "check_process_with_port error"
	fi
}

start_elk(){
	
	start_mode=$1
	check_process_with_port $e_port "elasticsearch" "nohint"
	es_run=$(echo $?)
	check_process_with_port $l_port "logstash" "nohint"
	logstash_run=$(echo $?)
	check_process_with_port $k_port "kibana" "nohint"
	kibana_run=$(echo $?)
	
	#grpc_run1=$SUCCESS_CODE
	#for port in  ${arrports[*]}
    #do
	#	check_process_with_port $port "huawei_dialout" "nohint"
	#	grpc_run1=$grpc_run1+$(echo $?)
	#done
	
	check_process_with_port $enterprise_dialout_port "enterprise_dialout" "nohint"
	grpc_run2=$(echo $?)
	#check_process_with_port "huawei_dialin" "nohint"
	#grpc_run3=$(echo $?)	

	if [ $es_run == $FAIL_CODE ]
	then
		# start up es,and log the start details to esstart.out
		touch /esstart.log
		touch /home/elkuser/esstart.log
		chmod 777 /esstart.log /home/elkuser/esstart.log
		cd "$ELK_INSTALL_DIR"/elasticsearch-5.5.0/bin
		su elkuser -c "nohup ./elasticsearch > /esstart.log 2>&1 &"
		sleep 2
	fi
	check_process_with_port $e_port "elasticsearch" "need_hint"

	if [ $kibana_run == $FAIL_CODE ]
	then
		# start up kibana, and log the details to kibanastart.log
		touch "$ELK_INSTALL_DIR"/kibana-5.5.0-linux-x86_64/kibanastart.log
		chmod 777 "$ELK_INSTALL_DIR"/kibana-5.5.0-linux-x86_64/kibanastart.log
		nohup "$ELK_INSTALL_DIR"/kibana-5.5.0-linux-x86_64/bin/kibana &> "$ELK_INSTALL_DIR"/kibana-5.5.0-linux-x86_64/kibanastart.log &		
		sleep 2
	fi
	check_process_with_port $k_port "kibana" "need_hint"

	if [ $logstash_run == $FAIL_CODE ]
	then
		# start up logstash
		cd "$ELK_INSTALL_DIR"/logstash-5.5.0	
		nohup ./bin/logstash -f huawei-test/unix_test.conf > start.log 2>&1 &		 
		cat >> "$ELK_INSTALL_DIR"/logstash-5.5.0/start.log <<EOF
<<<<<<<<<logstash startup succeeded!>>>>>>>
EOF
		start_logres=$FAIL_CODE
		until [  $start_logres == $SUCCESS_CODE ]
		do
			checkUnix=$(ls "$ELK_INSTALL_DIR"/logstash-5.5.0/huawei-test/|grep UNIX.d)
			if [[ $checkUnix =~ "UNIX.d" ]]
			then
				start_logres=$SUCCESS_CODE
			fi		
			sleep 1
		done
	fi
	check_process_with_port $l_port "logstash" "need_hint"
	huawei_dialout=$SUCCESS_CODE
	#if [ $grpc_run1 != $SUCCESS_CODE ]
	#then 
	if [ $start_mode == 'dialout_and_dialin' ] || [ $start_mode == "dialout" ]
	then			
		for port in  ${arrports[*]}
		do
			nohup python3 "$ELK_INSTALL_DIR"/HuaweiDialGrpc/huawei_dialout_server.py ${huawei_dialout_ip}:${port} > "$ELK_INSTALL_DIR"/HuaweiDialGrpc/huawei-dialout.log 2>&1 &
			check_process_with_port $port "huawei_dialout" "need_hint"		
			huawei_dialout=$huawei_dialout+$(echo $?)				
		done									
	else
		huawei_dialout=$SUCCESS_CODE # assume 0
	fi
	#else 
	#	echo ">>>>>> huawei dialout is running <<<<<<"
	#fi

	enterprise_dialout=$SUCCESS_CODE
	if [ $grpc_run2 == $FAIL_CODE ]
	then 
		if [ $start_mode == 'enterprise_dialout' ]
		then
			nohup python3 "$ELK_INSTALL_DIR"/HuaweiDialGrpc/enterprise_dialout_server.py ${enterprise_dialout_ip}:${enterprise_dialout_port} > "$ELK_INSTALL_DIR"/HuaweiDialGrpc/enterprise-dialout.log 2>&1 &
			check_process_with_port $enterprise_dialout_open "enterprise_dialout" "need_hint"
			enterprise_dialout=$(echo $?)		
		else
			enterprise_dialout=$SUCCESS_CODE # assume 0		
		fi
	else 
		echo ">>>>>> enterprise dialout is running <<<<<<"
	fi
	
	huawei_dialin=$SUCCESS_CODE
	#if [ $grpc_run3 == $FAIL_CODE ]
	#then
	if [ $start_mode == 'dialout_and_dialin' ] || [ $start_mode == "dialin" ]
	then
		nohup python3 "$ELK_INSTALL_DIR"/HuaweiDialGrpc/huawei_dialin_subscribe.py > "$ELK_INSTALL_DIR"/HuaweiDialGrpc/huawei-dialin.log 2>&1 &
		sleep 4
		grep "response_code: \"200\"" "$ELK_INSTALL_DIR"/HuaweiDialGrpc/huawei-dialin.log
		if [[ -n `grep "response_code: \"200\"" "$ELK_INSTALL_DIR"/HuaweiDialGrpc/huawei-dialin.log` ]]; then
			huawei_dialin=$SUCCESS_CODE
		else 
			huawei_dialin=$FAIL_CODE
		fi
		check_process_with_port "huawei_dialin" "need_hint"
		huawei_dialin=$(echo $?)		
	else
		huawei_dialin=$SUCCESS_CODE # assume 0		
	fi
	#else
	#	echo ">>>>>> huawei dialin is running <<<<<<"
	#fi
	
	es_start_res=$(echo $?)
	
	logstash_start_res=$(echo $?)
	check_process_with_port $k_port "kibana" "need_hint"
	kibana_start_res=$(echo $?)
	
	local start_res=$(($es_start_res+$logstash_start_res+$kibana_start_res+$huawei_dialout+$enterprise_dialout+$huawei_dialin))

	if [ $start_res == $SUCCESS_CODE ]
	then
		echo -e "\033[42;37m           ELK START UP SUCCESS !           \033[0m" 
		echo "########### please check url: http://${k_ip}:${k_port} ############"
		echo -e "\n"
	else
		echo -e "\033[41;37m           ELK START UP FAIL !           \033[0m"  
	fi
	
}

stop_program() {
	flag=$1
	program=$2
	if [ $flag == 0 ]
	then
		pid=`ps -ef -w -w|grep ${program}|grep -v grep|awk '{print $2}'`
		kill -9 $pid        
	fi
}

stop_elk() {
	# stop elk
	# before kill, check the port is on process
	echo "===================== check elk processes =========================="
	check_process_with_port $e_port "elasticsearch" "need_hint"
	es_run=$(echo $?)
	check_process_with_port $l_port "logstash" "need_hint"
	logstash_run=$(echo $?)
	check_process_with_port $k_port "kibana" "need_hint"
	kibana_run=$(echo $?)
	check_process_with_port "huawei_dialout"  "need_hint"
	grpc_run1=$(echo $?)
	check_process_with_port $enterprise_dialout_port "enterprise_dialout"  "need_hint"
	grpc_run2=$(echo $?)
	check_process_with_port "huawei_dialin"  "need_hint"
	grpc_run3=$(echo $?)	
	echo "=====================     stop elk        =========================="
	stop_program $grpc_run1 "huawei_dialout"
	stop_program $grpc_run2 "enterprise_dialout"
	stop_program $grpc_run3 "huawei_dialin"
	stop_program $logstash_run "logstash"	
	rm -f "$ELK_INSTALL_DIR"/logstash-5.5.0/huawei-test/UNIX.d	
	# stop kibana
	if [ $kibana_run == 0 ];then
		pid=`netstat -lntup|grep $k_port|awk -F '[ /]+' '{print $7}'`
		kill -9 $pid
	fi
	stop_program $es_run "elasticsearch"
	sleep 2
	echo "=====================  check after stop   =========================="
	check_process_with_port $e_port "elasticsearch"  "need_hint"
	es_stop=$(echo $?)
	check_process_with_port $l_port "logstash"  "need_hint"
	logstash_stop=$(echo $?)
	check_process_with_port $k_port "kibana"  "need_hint"
	kibana_stop=$(echo $?)
	
	if [ $huawei_dialout_open == 'true' ]
	then 
		check_process_with_port "huawei_dialout_server" "need_hint"
		grpc_stop1=$grpc_stop1+$(echo $?)
	else
		grpc_stop1=$FAIL_CODE #just a mark, ignore the parameter name
	fi
	
	if [ $enterprise_dialout_open == 'true' ]
	then 
		check_process_with_port $enterprise_dialout_port "enterprise_dialout" "need_hint"
		grpc_stop2=$(echo $?)
	else 
		grpc_stop2=$FAIL_CODE #just a mark, ignore the parameter name
	fi
	
	if [ $huawei_dialin_open == 'true' ]
	then 
		check_process_with_port "huawei_dialin" "need_hint"
		grpc_stop3=$(echo $?)
	else 
		grpc_stop3=$FAIL_CODE #just a mark, ignore the parameter name
	fi

	local stop_res=$(($es_stop*$logstash_stop*$kibana_stop*$grpc_stop1*$grpc_stop2*$grpc_stop3))
	
	if [ $stop_res == $FAIL_CODE ]
	then					
		echo -e "\033[42;37m           ELK STOPPED !           \033[0m" 
		return $SUCCESS_CODE		
	else 
		echo -e "\033[41;37m           ELK STOP FAIL !           \033[0m"  	
		return $FAIL_CODE		
	fi
}

set_proto() {

	# check ruby-protoc
	local ruby_protoc_v=$(ruby-protoc -v)		
	check_env -e "ruby-protoc " -r "." -h "ruby-protoc(v=1.6.1)" -c "$ruby_protoc_v" -s "yes" -t "string"
	ruby_protoc_env=$(echo $?)
	if [ $ruby_protoc_env == $FAIL_CODE ]
	then
		echo -e "\n"
		echo -e "\033[41;37m cannot find ruby-protoc command , please run ./huawei_elk_control install_ruby_protoc \033[0m"
		echo -e "\n"	
		exit 1
	fi
	# check if proto files are here
	proto_cnt=$(ls -l|grep "\.proto"|wc -l)
	if [ $proto_cnt == 0 ]
	then
		echo -e "\n"
		echo -e "\033[41;37m  No proto files under $ELK_FILES_DIR ! \033[0m"
		echo -e "\n"	
		exit 1
	fi
	
	# transfer protos
	if [ $ruby_protoc_env == $SUCCESS_CODE ]
	then		
		# proto3 to proto2		
		local protoc_res=$FAIL_CODE
		cd "$ELK_FILES_DIR"
		java -Dfile.encoding=utf-8 -jar proto3to2.jar *.proto
		local javatrans_res=$(echo $?)
		if [ $javatrans_res == $SUCCESS_CODE ]
		then 
			ruby-protoc *.proto
			local ruby_protoc_res=$(echo $?)		
			protoc_res=$ruby_protoc_res
		fi
		cp -f *.proto *.pb.rb "$ELK_INSTALL_DIR"/logstash-5.5.0/huawei-test/protos/
		echo -e "\n"
		if [ $protoc_res == $SUCCESS_CODE ]		
		then
			echo -e "\033[42;37m          CONGRATULATIONS! protos transfer successfully!          \033[0m"
		else
			echo -e "\033[41;37m          SORRY! protos transfer failed!          \033[0m"
		fi
		echo -e "\n"
	fi

}

function read_ini() {
	# read param value from ini file	
	section=$1
	option=$2
	iniFile=$3
	#value=`awk -F '=' '/\[${section}\]/{a=1}a==1' ${iniFile}|sed -e '1d' -e '/^$/d' -e '/^\[.*\]/,$d' -e "/^${option}=.*/!d" -e "s/^${option}=//"`
	INI_VALUE=`awk "/\[$section\]/{a=1}a==1" "$iniFile" | sed -e '1d' -e '/^$/d' -e '/^\[.*\]/,$d' -e "/$option=.*/!d" -e "s/$option=//g" | awk '$1=$1'`
}

function get_params() {
	if [ ! -f "$ELK_FILES_DIR"/HuaweiELK.ini ]
	then
		echo -e "\033[31m cannot find $ELK_FILES_DIR/HuaweiELK.ini \033[0m"
		exit 1
	fi

	# get all params from ini file
	read_ini "GRPC" "huawei_dialout_ip" "$ELK_FILES_DIR"/HuaweiELK.ini
	huawei_dialout_ip=$INI_VALUE

	read_ini "GRPC" "huawei_dialout_port" "$ELK_FILES_DIR"/HuaweiELK.ini
	huawei_dialout_ports=$INI_VALUE	
	arrports=($huawei_dialout_ports)
	
	read_ini "GRPC" "huawei_dialout_open" "$ELK_FILES_DIR"/HuaweiELK.ini
	huawei_dialout_open=$INI_VALUE	
	
	read_ini "GRPC" "enterprise_dialout_ip" "$ELK_FILES_DIR"/HuaweiELK.ini
	enterprise_dialout_ip=$INI_VALUE

	read_ini "GRPC" "enterprise_dialout_port" "$ELK_FILES_DIR"/HuaweiELK.ini
	enterprise_dialout_port=$INI_VALUE

	read_ini "GRPC" "enterprise_dialout_open" "$ELK_FILES_DIR"/HuaweiELK.ini
	enterprise_dialout_open=$INI_VALUE	

	read_ini "GRPC" "huawei_dialin_open" "$ELK_FILES_DIR"/HuaweiELK.ini
	huawei_dialin_open=$INI_VALUE		
		
	read_ini "Elasticsearch" "ip" "$ELK_FILES_DIR"/HuaweiELK.ini
	e_ip=$INI_VALUE	

	read_ini "Elasticsearch" "port" "$ELK_FILES_DIR"/HuaweiELK.ini
	e_port=$INI_VALUE

	read_ini "Logstash" "ip" "$ELK_FILES_DIR"/HuaweiELK.ini
	l_ip=$INI_VALUE
	
	read_ini "Logstash" "port" "$ELK_FILES_DIR"/HuaweiELK.ini
	l_port=$INI_VALUE
	
	read_ini "Kibana" "ip" "$ELK_FILES_DIR"/HuaweiELK.ini
	k_ip=$INI_VALUE
		
	read_ini "Kibana" "port" "$ELK_FILES_DIR"/HuaweiELK.ini
	k_port=$INI_VALUE
}

function uinstall_elk() {
	stop_elk
	rm -rf "$ELK_INSTALL_DIR"
	echo -e "\033[42;37m          ELK has removed!          \033[0m"
}

function main() {
	
	controlflag=$1	
	
	if [[ "$controlflag" =~ 'install' ]]
	then
		
		# check elk basic environment:jdk ruby rubygem python3 gcc
		check_elk_env 
		env_res=$(echo $?)	
	
		# check files are all ready or not		
		check_elk_files 
		files_res=$(echo $?)		
		
		local check_all_res=$(($env_res+$files_res))
		
		if (( $check_all_res > $SUCCESS_CODE ))
		then
			echo -e "\033[41;37m Please prepare files and enviroment in advance, else if ELK cannot be installed correctly \033[0m"
			exit 1
		fi	

		if [ "$controlflag" == 'install' ]		
		then						
			get_params
			# start install	
			if [ ! -d "$ELK_INSTALL_DIR" ] 
			then
				echo -e "\033[33m !! Now creating elk install dir !! \033[0m"	
				mkdir -p "$ELK_INSTALL_DIR"
			fi			
			install_elk_softwares
		fi
		
		if [ "$controlflag" == "install_ruby_protoc" ]
		then
			install_ruby_protoc
		fi
	fi
	
	# dialout_and_dialin
	if [ "$controlflag" == 'dialout_and_dialin' ]
	then
		
		stop_elk
		sleep 2
		get_params
		echo -e "\033[33m !! Now Start Up ELK with dialout and dialin grpc mode !! \033[0m"	 
		start_elk dialout_and_dialin
	fi	
	
	# dialout
	if [ "$controlflag" == 'dialout' ]
	then
		get_params
		echo -e "\033[33m !! Now Start Up ELK with dialout grpc mode !! \033[0m"	 
		start_elk dialout
	fi

	# dialin
	if [ "$controlflag" == 'dialin' ]
	then
		get_params
		echo -e "\033[33m !! Now Start Up ELK with dialin grpc mode !! \033[0m"	 
		start_elk dialin
	fi

	# stop
	if [ "$controlflag" == 'stop' ]
	then		
		get_params
		stop_elk	
	fi	
	
	# put protos
	if [ "$controlflag" == 'set_proto' ]
	then 		
		set_proto
	fi
	
	# check_elk_files
	if [ "$controlflag" == 'check_elk_files' ]
	then
		check_elk_files
	fi	
	
	# check_elk_env
	if [ "$controlflag" == 'check_elk_env' ]
	then
		check_elk_env
	fi		
	
	# uinstall
	if [ "$controlflag" == 'uinstall' ]
	then		
		uinstall_elk	
	fi	
	
}
controlflag=$1

# test params
if [ $# == 0 ] 
then 
	echo -e "\033[44;37m       <<<< you need add correct control mark >>>>       \033[0m"
	echo ">>>>>>>>>>>>> install : install elk softwares "
	echo ">>>>>>>>>>>>> uinstall : uinstall elk softwares " 
	echo ">>>>>>>>>>>>> stop : stop elk softwares "
	echo ">>>>>>>>>>>>> set_proto : put the telemetry protos , need put the proto files under $ELK_FILES_DIR in advance "
	echo ">>>>>>>>>>>>> dialout_and_dialin : start up elk softwares with dialout and dialin grpc mode" 
	echo ">>>>>>>>>>>>> dialout : start up elk softwares with dialout grpc mode" 
	echo ">>>>>>>>>>>>> dialin : start up elk softwares with dialin grpc mode" 
	echo ">>>>>>>>>>>>> cancel_huawei_dialin : cancel dialin subscription with ip:port subscribe_id request_id, like ./huawei_elk_control cancel_huawei_dialin 10.0.0.1:10004 1 1'"
	exit 1
fi

# debug
if [ "$controlflag" == 'debug' ]
then 
	echo "=====================now is debugging======================="	
	get_params
elif [ "$controlflag" == 'cancel_huawei_dialin' ]
then
	if [ $# -lt 4 ];then
		echo -e "\033[31m cancel_huawei_dialin params style is cancel_huawei_dialin ip:port subscribe_id request_id \033[0m"  
	fi
	nohup python3 "$ELK_INSTALL_DIR"/HuaweiDialGrpc/huawei_dialin_cancel.py -a $2 -s $3 -r $4 > "$ELK_INSTALL_DIR"/HuaweiDialGrpc/huawei-dialin-cancel.log 2>&1 &
	sleep 2
	grep "response_code: \"200\"" "$ELK_INSTALL_DIR"/HuaweiDialGrpc/huawei-dialin-cancel.log
	if [[ -n `grep "response_code: \"200\"" "$ELK_INSTALL_DIR"/HuaweiDialGrpc/huawei-dialin-cancel.log` ]]; then
		rescode_cancel=$SUCCESS_CODE
	else 
		rescode_cancel=$FAIL_CODE
	fi
	if [ $rescode_cancel == $SUCCESS_CODE ]
	then		
		echo -e "\033[42;37m          CANCEL HUAWEI DIALIN SUCCESS!            \033[0m" 			
	else
		echo -e "\033[41;37m          SORRY! CANCEL HUAWEI DIALIN FAILED!      \033[0m"
	fi
else
	main "$controlflag"	
fi
