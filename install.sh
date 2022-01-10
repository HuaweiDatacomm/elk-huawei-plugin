#!/bin/bash

elkhuaweiplugin_dir=$(pwd)
cp -r $elkhuaweiplugin_dir/huawei-test /usr/elk/logstash-5.5.0/
cp -r $elkhuaweiplugin_dir/local-plugins /usr/elk/logstash-5.5.0/
cp -r $elkhuaweiplugin_dir/logs /usr/elk/logstash-5.5.0/bin/
cp -r $elkhuaweiplugin_dir/HuaweiDialGrpc /usr/elk/

cat >> /usr/elk/logstash-5.5.0/Gemfile << EOF
gem "ruby-protocol-buffers", "1.6.1"
gem "logstash-codec-hw-telemetry-gpb", :path => "/usr/elk/logstash-5.5.0/local-plugins/logstash-codec-telemetry-gpb"
gem "logstash-input-unix-hw", :path => "/usr/elk/logstash-5.5.0/local-plugins/logstash-input-unix-hw"
EOF
