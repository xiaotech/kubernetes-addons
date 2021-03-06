# prometheus 配置总结

## 1. 添加自定义 target

```
- job_name: api
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /  # 修改默认监控path /metrics
  scheme: http
  static_configs:
  - targets:
    - 172.30.81.194:80
    labels:
      host: 172.30.81.194     
      instance: node-194_apache   # 添加labels，rules可以通过{{$labels.host}}引用
  - targets:
    - 172.30.81.193:80
    labels:
      host: 172.30.81.193
      instance: node-193_apache
```

** 注意: http://172.30.81.192/ 要返回node-exporter格式的数据，如 key value

*告警设置*

```
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - alertmanager-service:9093
    scheme: http
    timeout: 10s
rule_files:
- /etc/prometheus/rules/rules.yml
```

*rules.yaml配置*

```
groups:
  - name: down
    rules:
    - alert: node down
      expr: up{job="worker node"} == 0
      labels:
        severity: Fatal
      annotations:
        description: "{{ $labels.instance }}  is down"
    - alert: apache2 down
      expr: apache_health{job="api"} == 0
      labels:
        severity: Error
      annotations:
        description: "{{ $labels.instance }} of {{ $labels.host }}  is down"
```


*alertmanager设置*

```
global:
  resolve_timeout: 5m
  http_config: {}
  smtp_hello: localhost
  smtp_require_tls: true
  pagerduty_url: https://events.pagerduty.com/v2/enqueue
  hipchat_api_url: https://api.hipchat.com/
  opsgenie_api_url: https://api.opsgenie.com/
  wechat_api_url: https://qyapi.weixin.qq.com/cgi-bin/
  victorops_api_url: https://alert.victorops.com/integrations/generic/20131114/alert/
route:
  receiver: wechat
  group_by:
  - alertname
receivers:
- name: wechat
  wechat_configs:
  - send_resolved: false
    http_config: {}
    api_secret: <secret>
    corp_id: ww9dfb5b4aada9b647
    message: '{{ template "wechat.default.message" . }}'
    api_url: https://qyapi.weixin.qq.com/cgi-bin/
    to_user: '{{ template "wechat.default.to_user" . }}'
    to_party: "2"
    to_tag: '{{ template "wechat.default.to_tag" . }}'
    agent_id: "1000004"
templates:
- /etc/alertmanager/template/wechat.tmpl
```

*webchat报警模板*

```
{{ define "wechat.default.message" }} {{ range .Alerts }}
    ========告警========== 
    告警级别：{{ .Labels.severity }} 
    告警类型：{{ .Labels.alertname }} 
    告警详情: {{ .Annotations.description }} 
    触发时间: {{ .StartsAt.Format "2006-01-02 15:04:05" }} 
    ===================== 
    {{ end }} 
    {{ end }}
```

* 修改 nfs地址
* 修改target
* 修改rule


## 2. alertmanager 告警

* 分组： 同组的告警只发送一条，根据alertname, group_by

* 抑制:  有A引发的B，C告警，只发送A, inhibit{source_match相当于A;target_match相当于B，C;equal匹配的label}

* 沉默： 根据规则过滤告警，不发送

> 变量参考 https://prometheus.io/docs/alerting/notifications/#alert

> prometheus文档参考 https://yunlzheng.gitbook.io/prometheus-book/


## 3. prometheus服务发现

* 基于文件的发现

```
scrape_configs:
- job_name: 'file_ds'
  file_sd_configs:
  - files:
    - targets.json


[
  {
    "targets": [ "localhost:8080"],
    "labels": {
      "env": "localhost",
      "job": "cadvisor"
    }
  },
  {
    "targets": [ "localhost:9104" ],
    "labels": {
      "env": "prod",
      "job": "mysqld"
    }
  },
  {
    "targets": [ "localhost:9100"],
    "labels": {
      "env": "prod",
      "job": "node"
    }
  }
]

```

* 基于consul的服务发现

```
- job_name: node_exporter
    metrics_path: /metrics
    scheme: http
    consul_sd_configs:
      - server: localhost:8500
        services:
          - node_exporter
```

* 基于sd的服务发现,如kubernetes_sd_configs

* relabel_configs: 修改label，过滤

*replace*

```
  relabel_configs:
  - source_labels: ["__meta_consul_dc"]
    target_label: "datacenter"
    replacement: "this is test{$1}"
    action: replace
```

*labelmap,会将匹配到的数据，名称和value作为新的label，名称为()中的匹配*

```
  relabel_configs:
  - action: labelmap
    regex: __meta_consul_(.+)
```

*过滤*

```
    relabel_configs:
    - source_labels:  ["__meta_consul_dc"]
      regex: "dc1"
      action: keep   #drop
```


## 4. 高可用

* prometheus 本地存储

* prometheus 远程存储

* prometheus: federation扩展

```
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s


scrape_configs:
- job_name: 'federate'
  metrics_path: '/federate'
  params:
    'match[]':
      - '{job=~ ".+"}'
  static_configs:
  - targets: 
    - "172.30.81.186:32665"
```

* prometheus HA

- ha + 本地存储: 无法解决数据一致性问题

- ha + 远程存储： 可以很好解决数据一致性问题
 
- ha + 远程存储 + federation: 联邦机制加入可以解决数据采集的性能问题

* alertmanager: gossip协议集群交互

alertmanager 

多个prometheus推送相同的报警信息给alertmanager，分组机制 只会发送一个，

但是alertmanager存在单点问题,部署多个需要信息同步

gossip协议用于分布式节点信息交换和同步，类似与病毒传播

主要有pull和push模式，如发送通知后会push消息，启动阶段会pull 状态

集群创建启动时添加下面参数
```
    --cluster.listen-address string: 当前实例集群服务监听地址

    --cluster.peer value: 初始化时关联的其它实例的集群服务地址

```
