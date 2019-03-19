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
