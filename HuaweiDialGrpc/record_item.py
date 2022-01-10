#!/usr/bin/env python
# -*- coding: utf-8 -*-

class RecordItem(object):
    def __init__(self,subscribe_id,request_id,dialin_server,message,type):
        self.subscription_id = subscribe_id
        self.request_id = request_id
        self.dialin_server=dialin_server
        self.type=type
        self.message = message

    def __eq__(self, other):
        if self.type == "record_id" and self.subscription_id == other.subscription_id and self.request_id == other.request_id and self.dialin_server == other.dialin_server:
            return True
        else:
            return False

    def __hash__(self):
        return hash(self.subscription_id)

    def to_log(self):
        if (self.type == "record_id"):
            log = "dialin_server " + str(self.dialin_server) + " subscription_id: " + str(
                    self.subscription_id) + " ,request_id: " + str(self.request_id) +"\n"
        elif (self.type == "error"):
            # 如果订阅回复异常，也记到日志中
            log = "dialin_server " + str(self.dialin_server) + " description: " + str(self.message)+"\n"
        return log