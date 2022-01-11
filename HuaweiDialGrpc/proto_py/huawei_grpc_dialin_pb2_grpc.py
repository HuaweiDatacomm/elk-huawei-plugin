# Generated by the gRPC Python protocol compiler plugin. DO NOT EDIT!
import grpc

import huawei_grpc_dialin_pb2 as huawei__grpc__dialin__pb2


class gRPCConfigOperStub(object):
    """The service name is gRPCConfigOper.
    """

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.Subscribe = channel.unary_stream(
                '/huawei_dialin.gRPCConfigOper/Subscribe',
                request_serializer=huawei__grpc__dialin__pb2.SubsArgs.SerializeToString,
                response_deserializer=huawei__grpc__dialin__pb2.SubsReply.FromString,
                )
        self.Cancel = channel.unary_unary(
                '/huawei_dialin.gRPCConfigOper/Cancel',
                request_serializer=huawei__grpc__dialin__pb2.CancelArgs.SerializeToString,
                response_deserializer=huawei__grpc__dialin__pb2.CancelReply.FromString,
                )


class gRPCConfigOperServicer(object):
    """The service name is gRPCConfigOper.
    """

    def Subscribe(self, request, context):
        """Missing associated documentation comment in .proto file"""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def Cancel(self, request, context):
        """Missing associated documentation comment in .proto file"""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_gRPCConfigOperServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'Subscribe': grpc.unary_stream_rpc_method_handler(
                    servicer.Subscribe,
                    request_deserializer=huawei__grpc__dialin__pb2.SubsArgs.FromString,
                    response_serializer=huawei__grpc__dialin__pb2.SubsReply.SerializeToString,
            ),
            'Cancel': grpc.unary_unary_rpc_method_handler(
                    servicer.Cancel,
                    request_deserializer=huawei__grpc__dialin__pb2.CancelArgs.FromString,
                    response_serializer=huawei__grpc__dialin__pb2.CancelReply.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'huawei_dialin.gRPCConfigOper', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))


 # This class is part of an EXPERIMENTAL API.
class gRPCConfigOper(object):
    """The service name is gRPCConfigOper.
    """

    @staticmethod
    def Subscribe(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_stream(request, target, '/huawei_dialin.gRPCConfigOper/Subscribe',
            huawei__grpc__dialin__pb2.SubsArgs.SerializeToString,
            huawei__grpc__dialin__pb2.SubsReply.FromString,
            options, channel_credentials,
            call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def Cancel(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/huawei_dialin.gRPCConfigOper/Cancel',
            huawei__grpc__dialin__pb2.CancelArgs.SerializeToString,
            huawei__grpc__dialin__pb2.CancelReply.FromString,
            options, channel_credentials,
            call_credentials, compression, wait_for_ready, timeout, metadata)
