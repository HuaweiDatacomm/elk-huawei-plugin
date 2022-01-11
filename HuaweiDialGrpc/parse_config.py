#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import json

def get_config_data():
    if os.path.exists(os.path.abspath(os.path.join(os.path.dirname(__file__), "conf", "config.json"))):
        conf_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "conf", "config.json"))
        with open(conf_path, 'r') as f:
            try:
                data = json.load(f)
            except Exception as e:
                sys.stderr.write(": Error : conf.json format error !\n")
        return data
    else:
        sys.stderr.write(": Error : config.json is not found !\n")


def get_address():
    data = get_config_data()
    add = []
    container = data.get('routers')
    for con in container:
        add.append(con.get('address'))
    return add, container


def get_socket_address():
    data = get_config_data()
    socket_address = data.get('socket_address')
    return socket_address


def get_json_dict():
    try:
        config_dict = {}
        address, container = get_address()
        if not container:
            sys.stderr.write(": Error :config.json is empty \n!")
        for add in address:
            if not add:
                sys.stderr.write(": Error :config.json is not configuration address !\n")
                break

            conf = ConfigJson()
            metadata = conf.get_config_metadata(add, container)
            paths = conf.get_config_paths(add, container)
            request_id = conf.get_config_request_id(add, container)
            sample_interval = conf.get_config_sample_interval(add, container)
            node_dict = {}
            node_dict['metadata'] = metadata
            node_dict['paths'] = paths
            node_dict['request_id'] = request_id
            node_dict['sample_interval'] = sample_interval
            config_dict[add] = node_dict
    except Exception:
        sys.stderr.write(": Error :config.json parsing failed !\n")
    return config_dict


class ConfigJson(object):

    def __init__(self):
        self.metadata = None
        self.paths = None
        self.request_id = None
        self.sample_interval = None

    def get_config_metadata(self, add, container):
        for contain_dict in container:
            if contain_dict.get("address") == add:
                self.metadata = (
                    ('username', contain_dict.get('aaa').get("username")),
                    ('password', contain_dict.get('aaa').get("password")))
        return self.metadata

    def get_config_paths(self, add, container):
        for contain_dict in container:
            if contain_dict.get("address") == add:
                self.paths = contain_dict.get('Paths')
        return self.paths

    def get_config_request_id(self, add, container):
        for contain_dict in container:
            if contain_dict.get("address") == add:
                self.request_id = contain_dict.get('request_id')
        return self.request_id

    def get_config_sample_interval(self, add, container):
        for contain_dict in container:
            if contain_dict.get("address") == add:
                self.sample_interval = contain_dict.get('sample_interval')
        return self.sample_interval
