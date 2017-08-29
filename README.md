# zabbix-nginx
zabbix nginx监控改良  
nginx版本1.12.1  
########  
1、解决了一般zabbix监控数据不是同时采集的问题，改成统一上传到采集器的方案。  
2、自动发现nginx access log，并统计日志中大于500状态码报警  
3、通过check_status对后端server可用性指标做了监控  
########  
