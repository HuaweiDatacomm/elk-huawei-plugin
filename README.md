# **elk-huawei-plugin**

## **Overview**
the huawei plugin for elk to collect and process information from huawei devices

## **Installation**
### **Prerequisites**

- OS : Ubuntu, CentOS, Suse, Red Hat
- Java : 1.8 (warning: do not install in dir root)
- Python : 3.6
- Ruby :2.7


### Build From Source

1. new folder in dir /usr:
   ```
   cd /usr
   rm -rf elk
   mkdir elk
   ```
2. download elkfiles,then put these in dir /usr/elk:   
elasticsearch: https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.5.0.tar.gz  
logstash: https://artifacts.elastic.co/downloads/logstash/logstash-5.5.0.tar.gz  
kibana: https://artifacts.elastic.co/downloads/kibana/kibana-5.5.0-linux-x86_64.tar.gz  
Platform-0.4.2.gem: https://rubygems.org/downloads/Platform-0.4.2.gem  
protoc-2.6.1.gem: https://rubygems.org/downloads/protoc-2.6.1.gem  
ruby-protocol-buffers-1.6.1.gem: https://rubygems.org/downloads/ruby-protocol-buffers-1.6.1.gem


4. extract elk:
   ```
   cd /usr/elk
   tar -zxvf elasticsearch-5.5.0.tar.gz
   tar -zxvf logstash-5.5.0.tar.gz
   tar -zxvf kibana-5.5.0-linux-x86_64.tar.gz
   ```
5. install gems:
   ```
   cd /usr/elk
   vim /etc/profile
   export GEM_HOME=/usr/elk/logstash-5.5.0/vendor/bundle/jruby/1.9
   source /etc/profile
   gem install Platform-0.4.2.gem
   gem install protoc-2.6.1.gem
   gem install ruby-protocol-buffers-1.6.1.gem
   ruby-protoc -v
   ```
6. clone elk-huawei-plugin:
   ```
   git clone https://github.com/HuaweiDatacomm/elk-huawei-plugin.git
   ```
7. install elk-huawei-plugin(warning: run install.sh only once):
   ```
   cd /elk-huawei-plugin
   chmod +x install.sh
   ./install.sh
   ```
8. put protos in dir elk-huawei-plugin and transfer protos,then generate the file of proto, put these in dir /usr/elk/logstash-5.5.0/huawei-test/protos
   ```
   cd /elk-huawei-plugin
   java -Dfile.encoding=utf-8 -jar proto3to2.jar *.proto
   ruby-protoc *.proto
   cp -f *.proto *.pb.rb /usr/elk/logstash-5.5.0/huawei-test/protos/
   ```
9. add elasticsearch's configuration(warning:pay attention to the spaces):
   ```
   cd /usr/elk/elasticsearch-5.5.0/config
   vim elasticsearch.yml
   network.host: 127.0.0.1
   http.port: 9200
   bootstrap.system_call_filter: false
   ```
10. add kibana's configuration(warning: pay attention to the spaces):
    ```
    cd /usr/elk/kibana-5.5.0-linux-x86_64/config
    vim kibana.yml
    server.port: "5601"
    server.host: "127.0.0.1"
    elasticsearch.url: "http://127.0.0.1:9200"
    ```
11. download grpcio and protobuf
    ```
    pip3 install grpcio
    pip3 install protobuf
    ```

## Getting Used
  
ELK is the acronym for three open-source projects: Elasticsearch, Logstash, and Kibana. 
The ELK tool is an open-source O&M tool and can be installed on multiple platforms, such as Linux . 
Details about Elasticsearch, Logstash, and Kibana are as follows:  
 - Elasticsearch is developed based on Java. It is a real-time full-text search and analytics engine and provides three functions: collection, analysis, and storage of data.  
 - Logstash is developed based on Ruby and is a tool for collecting, analyzing, and filtering data. It works based on plug-ins and does not have the capability to receive or 
convert telemetry data. Modules running on Logstash provide the capability to receive or convert telemetry data, whereas Logstash provides a framework only. The framework 
consists of the following:
 - Kibana is a web-based graphical user interface (GUI) developed for search purposes. It can analyze and visualize data stored on Elasticsearch. It uses the REST interface of
Elasticsearch to retrieve data.  

1. start elasticsearch:
   ```
   groupadd elkgroup
   useradd elkuser -g elkgroup
   mkdir /home/elkuser
   chown -R elkuser:elkgroup /usr/elk/elasticsearch-5.5.0
   cd /usr/elk/elasticsearch-5.5.0/bin
   su elkuser
   ./elasticsearch
   ```
2. start kibana:
   ```
   cd /usr/elk/kibana-5.5.0-linux-x86_64/bin
   ./kibana
   ``` 
3. start logstash:
   ```
   cd /usr/elk/logstash-5.5.0
   rm -rf data
   cd /usr/elk/logstash-5.5.0/huawei-test
   touch UNIX.d
   cd /usr/elk/logstash-5.5.0/bin
   ./logstash -f ../huawei-test/unix_test.conf
   ```
4. modify HuaweiDialGrpc's config:
   ```
   cd HuaweiDialGrpc/conf
   vim config.json
   ####################elk-huawei-dialin#############################################
   ## username: device's name
   ## password: device's password
   ## sample_interval: sampling interval
   ## path: sampling path. such as "huawei-debug:debug/cpu-infos/cpu-info"
   ## depth: sampling depth
   ```
5. start HuaweiDialGrpc:
   ```
   cd /usr/elk/HuaweiDialGrpc
   python3 huawei-dialin-subcribe.py 
   ```
6. use kibana
 - Open the browser and enter the following URL
   http://127.0.0.1:5601
 - Management => Index Patterns
 - Index name or pattern : logstash-telemetry-* 
 - Time Filter field name : @timestamp
 - Create
 - Discover
   






