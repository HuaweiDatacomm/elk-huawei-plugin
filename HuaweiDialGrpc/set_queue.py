#!/usr/bin/env python
# -*- coding: utf-8 -*-

import copy
from queue import Queue

# 一个不能添加重复数据的 queue
class SetQueue(Queue):
    def _init(self, size):
        self.size = size
        self.queue = Queue()
        self.set_items = set()

    def __str__(self):
        return str(self.queue)

    def enqueue(self, item):
        if self.is_full():
            return -1
        # 如果已经加过这个元素，则不再加入
        temp_set = copy.deepcopy(self.set_items)
        self.set_items.add(item)
        if (temp_set == self.set_items):
            return -1
        else:
            self.queue.append(item)

    # 出队，如果队列空了返回-1或抛出异常，否则返回队列头元素并将其从队列中移除
    def dequeue(self):
        if self.is_empty():
            return -1
        firstElement = self.queue[0]
        self.queue.remove(firstElement)
        return firstElement

    # 判断队列满
    def is_full(self):
        if len(self.queue) == self.size:
            return True
        return False

    # 判断队列空
    def is_empty(self):
        if len(self.queue) == 0:
            return True
        return False
