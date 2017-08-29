# --*-- coding=utf-8 --*--
import urllib2
import urllib
import json
import  socket

hostName = socket.gethostname()
nginx_statusHtml = urllib.urlopen("http://" + hostName + "/status?format=json&status=down")
#通过urllib模块中的urlopen的方法打开url
nginx_statusHtml1 = nginx_statusHtml.read()
#通过read方法获取返回数据
#print "url返回的json数据：",nginx_statusHtml1
#打印返回信息
nginx_statusJSON = json.loads(nginx_statusHtml1)
try:
    down_num = nginx_statusJSON["servers"]["total"]
    print down_num
except Exception,e:
    print Exception,":",e
#将返回的json格式的数据转化为python对象，json数据转化成了python中的字典，按照字典方法读取数据
