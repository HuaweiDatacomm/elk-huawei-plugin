import codecs
import datetime
import threading
import time

DIALIN_SUB_LOG = "dialin_subcribes.log"
ISOTIMEFORMAT = '%Y-%m-%d %H:%M:%S,f'


class RecordToLog(threading.Thread):
    """

    """

    def __init__(self, t_name,  log_set, get_interval):
        threading.Thread.__init__(self,name=t_name)
        self.t_name = t_name
        self.log_set = log_set
        self.get_interval = get_interval

    def run(self):
        while True:
            if len(self.log_set) is not 0:
                record = self.log_set.pop()
                time_now = datetime.datetime.now().strftime(ISOTIMEFORMAT)
                with codecs.open(DIALIN_SUB_LOG, 'a+', 'utf-8') as logfile:
                    logfile.write("time: " + time_now + record.to_log())
                time.sleep(self.get_interval)

class SendToSock(threading.Thread):
    def __init__(self, t_name, data_queue,sock, get_interval):
        threading.Thread.__init__(self,name=t_name)
        self.t_name = t_name
        self.data_queue = data_queue
        self.sock = sock
        self.get_interval = get_interval

    def run(self):
        while True:
            if not self.data_queue.empty():
                data = self.data_queue.get(block=True, timeout=0)
                print(" send to sock ----------------------------------------")
                print(data.data_len + data.message, "\n")
                self.sock.send(data.data_len + data.message)
                time.sleep(self.get_interval)
            # 适配proto3解码的发包方式
            # sock.send(data_len + dataMarkByte + sub_resp.message)
            # 适配proto2解码的发包方式


