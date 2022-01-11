#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

import socket
import sys
import time
from concurrent import futures

import grpc

from openconfig import dialout_pb2_grpc

_ONE_DAY_IN_SECONDS = 60 * 60 * 24
sys.path.append("/usr/elk/HuaweiDialGrpc/openconfig")
class EnterPriseDialoutServer(dialout_pb2_grpc.DialoutServicer):
    def __init__(self):
        print("EnterPriseDialoutServer init")
        return

    def Dialout(self, request_iterator, context):
        print("server MdtDialout")
        for _MdtDialoutArgs in request_iterator:
            print(_MdtDialoutArgs.data.value)
            data_len = (len(_MdtDialoutArgs.data.value)).to_bytes(4, byteorder='big')
            dataMark = 0
            dataMarkByte = dataMark.to_bytes(2, byteorder='big')
            sock.send(data_len + dataMarkByte + _MdtDialoutArgs.data.value)
            print(data_len + _MdtDialoutArgs.data.value, "\n")


def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=150))
    dialout_pb2_grpc.add_DialoutServicer_to_server(
        EnterPriseDialoutServer(), server)
    print("sys.argv[1]:"+sys.argv[1])
    server.add_insecure_port(sys.argv[1])
    server.start()
    try:
        while True:
            time.sleep(_ONE_DAY_IN_SECONDS)

    except KeyboardInterrupt:
        server.stop(0)
        sock.close()


if __name__ == '__main__':
    if len(sys.argv) <= 1:
        print("!!!input eror!!!")
        print("%s ip:port logfile" % sys.argv[0])
        sys.exit(1)

    global sock
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect("/usr/elk/logstash-5.5.0/huawei-test/UNIX.d")
    time.sleep(2)
    serve()
