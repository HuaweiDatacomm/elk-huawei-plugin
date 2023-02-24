#!/usr/bin/env python
# -*- coding: utf-8 -*-
import signal
import sys
import time

import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "proto_py")))
from consumer_thread import RecordToLog, SendToSock
from global_args import GlobalArgs
from producer_thread import DataPublish

# 处理信号程序
def handle(signum,frame):
    print("Stopping...")
    print("Now start to cancel huawei dialout in this python process...")
    sys.exit(1)

# 主方法入口
if __name__ == '__main__':

    if len(sys.argv) <= 1:
        print("!!!input eror!!!")
        print("%s ip:port" % sys.argv[0])
        sys.exit(1)


    # 监听CTRL C 和 kill -9指令
    signal.signal(signal.SIGINT, handle)
    signal.signal(signal.SIGTERM, handle)

    # 初始化 log_queue, data_queue
    log_set = set()
    data_queue = GlobalArgs.get_data_queue()
    global ids_set
    ids_set = log_set

    try:
        # 创建消费者线程
        # 开启sock线程
        sock = GlobalArgs.get_sock()
        sock_thread = SendToSock("[ sock_thread ]", data_queue, sock, GlobalArgs.FLUSH_INTERVAL)
        sock_thread.setDaemon(True)
        sock_thread.start()
        # 开启log线程
        log_thread = RecordToLog("[ log_thread ]", log_set, GlobalArgs.FLUSH_INTERVAL)
        log_thread.setDaemon(True)
        log_thread.start()

        time.sleep(GlobalArgs.CONNECT_WAIT_TIME)  # 暂停2s，等待消费者线程准备就绪

        # 创建生产者线程，并开启
        thread_name = "[dialout] DataPublish "
        datapublish_thread = DataPublish(thread_name,data_queue,sys.argv[1] )
        datapublish_thread.setDaemon(False)
        datapublish_thread.start()
    except Exception as e:
        print(e)

