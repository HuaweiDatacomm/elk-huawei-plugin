#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2015, Huawei Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#     * Neither the name of Huawei Inc. nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

"""The Python implementation of the gRPC route guide server."""

from __future__ import print_function

import os
import queue
import threading
from concurrent import futures
import time
import math
import sys
import socket

import parse_config

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "proto_py")))

import grpc
from proto_py import huawei_grpc_dialout_pb2_grpc

_ONE_DAY_IN_SECONDS = 60 * 60 * 24


class MdtGrpcDialOutServicer(huawei_grpc_dialout_pb2_grpc.gRPCDataserviceServicer):
    def __init__(self):
        return

    def dataPublish(self, request_iterator, context):
        for _MdtDialoutArgs in request_iterator:
            if (len(_MdtDialoutArgs.data) == 0):
                print("server MdtDialout JSON")
                json2Bytes = bytes(_MdtDialoutArgs.data_json, encoding="utf8")
                # jsonMark = 1
                # jsonMarkByte = jsonMark.to_bytes(2, byteorder='big')
                data_len = (len(json2Bytes)).to_bytes(4, byteorder='big')
                # sock.send(data_len+jsonMarkByte+json2Bytes)
                sock.send(data_len + json2Bytes)
            else:
                print("server MdtDialout GPB")
                gpbMark = 0
                gpbMarkByte = gpbMark.to_bytes(2, byteorder='big')
                data_len = (len(_MdtDialoutArgs.data)).to_bytes(4, byteorder='big')
                # sock.send(data_len + gpbMarkByte + _MdtDialoutArgs.data)
                sock.send(data_len + _MdtDialoutArgs.data)
                print(data_len + _MdtDialoutArgs.data, "\n")


def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=150))
    huawei_grpc_dialout_pb2_grpc.add_gRPCDataserviceServicer_to_server(
        MdtGrpcDialOutServicer(), server)

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
    socket_target = parse_config.get_socket_address()
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(socket_target)
    time.sleep(2)
    serve()
