#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import grpc
import os
from optparse import OptionParser
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "proto_py")))
from proto_py import huawei_grpc_dialin_pb2_grpc
from proto_py import huawei_grpc_dialin_pb2
from parse_config import get_json_dict

def cancel(stub, subscription_id, request_id, metadata):
    try:
        cancelArg = huawei_grpc_dialin_pb2.CancelArgs()
        cancelArg.subscription_id = subscription_id
        cancelArg.request_id = request_id
        cancel_resps = stub.Cancel(cancelArg, metadata=metadata)
        print(cancel_resps)
        if not cancel_resps:
            sys.stderr.write(": Error : Cancel response in none !\n")
        else:
            sys.exit(0)
    except Exception as e:
        sys.stderr.write(": Error : Cancel error !\n")
        sys.exit(1)


def generate_sub_args(request_id=1, encoding=1, path=[], sample_interval=10000):
    return huawei_grpc_dialin_pb2.SubsArgs(request_id=request_id, encoding=encoding, path=path,
                                           sample_interval=sample_interval)

def create_client_cancel(address,subscription_id,request_id):
    channel = grpc.insecure_channel(address)
    stub = huawei_grpc_dialin_pb2_grpc.gRPCConfigOperStub(channel)
    config_json = get_json_dict()
    if config_json:
        if config_json.get(address):
            metadata_dict = config_json[address]['metadata']
            cancel(stub, subscription_id, request_id,metadata_dict)
    else:
        sys.exit()


def parse_args():
    """Parse the user input.
    Returns:
        options: The instance record user input.
        args: The list record arguments.
    """
    parser = OptionParser()

    parser.add_option("-a", "--address", dest="address", default='')
    parser.add_option("-s", "--subscription_id", dest="subscription_id", default='')
    parser.add_option("-r", "--request_id", dest="request_id", default='')

    (options, args) = parser.parse_args()
    return options, args

def env_parse():
    """Get user input from the command line.
    Returns:
        options: The instance record user input.
    """
    (options, args) = parse_args()
    return options

if __name__ == '__main__':
    options = env_parse()
    address = options.address
    subscription_id = options.subscription_id
    request_id = options.request_id
    if address == "":
        sys.stderr.write(": Error : Please input -a address !\n")
    if subscription_id == "":
        sys.stderr.write(": Error : Please input -a subscription_id !\n")
    if request_id == "":
        sys.stderr.write(": Error : Please input -a request_id!\n")
    try:
        subscription_id = int(subscription_id)
    except Exception as e:
        sys.stderr.write(": Error : subscription_id must be int !\n")
    try:
        request_id = int(subscription_id)
    except Exception as e:
        sys.stderr.write(": Error : request_id must be int !\n")
    create_client_cancel(address,subscription_id,request_id)
