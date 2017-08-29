# zabbix-nginx
zabbix nginx监控改良
nginx版本1.12.1
########
1、解决了一般zabbix监控数据不是同时采集的问题，改成统一上传到采集器的方案。
2、自动发现nginx access log，并统计日志中大于500状态码报警
3、通过check_status对后端server可用性指标做了监控
########

基本活跃指标
使用stub_status采集，下图是一个客户端连接的过程，以及NGINX 如何在连接过程中收集指标

Accepts（接受）	NGINX 所接受的客户端连接数	资源: 功能
Handled（已处理）	成功的客户端连接数	资源: 功能
Active（活跃）	当前活跃的客户端连接数	资源: 功能
Dropped（已丢弃，计算得出）	丢弃的连接数（接受 - 已处理）	工作：错误*
Requests（请求数）	客户端请求数	工作：吞吐量
名称
描述
指标类型
*严格的来说，丢弃的连接是 一个资源饱和指标，但是因为饱和会导致 NGINX 停止服务（而不是延后该请求），所以，“已丢弃”视作 一个工作指标 比较合适。
NGINX worker 进程接受 OS 的连接请求时 Accepts 计数器增加，而Handled 是当实际的请求得到连接时（通过建立一个新的连接或重新使用一个空闲的）。这两个计数器的值通常都是相同的，如果它们有差别则表明连接被Dropped，往往这是由于资源限制，比如已经达到 NGINX 的worker_connections的限制。
一旦 NGINX 成功处理一个连接时，连接会移动到Active状态，在这里对客户端请求进行处理：
Active状态
Waiting: 活跃的连接也可以处于 Waiting 子状态，如果有在此刻没有活跃请求的话。新连接可以绕过这个状态并直接变为到 Reading 状态，最常见的是在使用“accept filter（接受过滤器）” 和 “deferred accept（延迟接受）”时，在这种情况下，NGINX 不会接收 worker 进程的通知，直到它具有足够的数据才开始响应。如果连接设置为 keep-alive ，那么它在发送响应后将处于等待状态。
Reading: 当接收到请求时，连接离开 Waiting 状态，并且该请求本身使 Reading 状态计数增加。在这种状态下 NGINX 会读取客户端请求首部。请求首部是比较小的，因此这通常是一个快速的操作。
Writing: 请求被读取之后，其使 Writing 状态计数增加，并保持在该状态，直到响应返回给客户端。这意味着，该请求在 Writing 状态时， 一方面 NGINX 等待来自上游系统的结果（系统放在 NGINX “后面”），另外一方面，NGINX 也在同时响应。请求往往会在 Writing 状态花费大量的时间。
通常，一个连接在同一时间只接受一个请求。在这种情况下，Active 连接的数目 == Waiting 的连接 + Reading 请求 + Writing 。然而，较新的 SPDY 和 HTTP/2 协议允许多个并发请求/响应复用一个连接，所以 Active 可小于 Waiting 的连接、 Reading 请求、Writing 请求的总和。 
提醒指标: 丢弃连接
Dropped＝Accepts－Handled，大于0即需要关注
提醒指标: 每秒请求数
requests差量每秒，请求量波动过大需要关注
 
错误指标
提醒指标: 服务器错误数监控
使用nginx日志统计，扫描找到nginx日志文件，监控日志中$status字段>500个数报警
反向代理指标
可用性指标
tengine从http://xxxx.ymt.io/status?format=json获取status=down指标server个数报警:nginx_status_num
