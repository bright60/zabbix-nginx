#!/usr/bin/env python
import os
import json
t=os.popen("""find /data/logs/nginx/ -name "*log"|awk -F "/" '{print $NF}'""")
nginxlog = []
for port in  t.readlines():
        r = os.path.basename(port.strip())
        nginxlog += [{'{#NGINXLOG}':r}]
print json.dumps({'data':nginxlog},sort_keys=True,indent=4,separators=(',',':'))
