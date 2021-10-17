# -*- coding:utf-8 -*-
# @Time: 2021/10/10 13:14
# @Author: Zhengwu Cai
# @Email: zhengwupal@163.com
import os
import time

while True:
    shim_pid = os.system('pgrep -f docker-containerd-shim-current')
    print(shim_pid)
    if not shim_pid:
        result = os.system('sh ps.sh')
        print(result)

    print(time.ctime())
    time.sleep(1)
