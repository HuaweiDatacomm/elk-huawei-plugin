#!/usr/bin/env python
# -*- coding: utf-8 -*-
import socket
from queue import Queue

import parse_config

class GlobalArgs(object):
    _ONE_DAY_IN_SECONDS = 60 * 60 * 24
    LOG_QUEUE_SIZE = 10000
    DATA_QUEUE_SIZE = 10000
    CONNECT_WAIT_TIME = 2   # seconds
    FLUSH_INTERVAL = 1
    RECORD_TYPE = "record_id"
    ERROR_TYPE = "error"
    data_queue = None
    sock = None

    @staticmethod
    def get_data_queue():
        if GlobalArgs.data_queue is None:
            GlobalArgs.data_queue = Queue(GlobalArgs.DATA_QUEUE_SIZE)
        return GlobalArgs.data_queue

    @staticmethod
    def get_sock():
        if GlobalArgs.sock is None:
            socket_target = parse_config.get_socket_address()
            sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            sock.connect(socket_target)
            GlobalArgs.sock = sock
        return GlobalArgs.sock




