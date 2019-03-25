# blackbox 黑盒测试 http，icmp，tcp，dns，ssl


*以http post测试为例*

## 1. blackbox配置文件

```
modules:
  http_2xx:
    prober: http
  http_post_2xx:
    prober: http
    http:
      method: POST
      headers:
        Content-Type: application/json
      body: '{"hmac":"","params":{"publicFundsKeyWords":"xxx"}}'
```

## 2. prometheus配置文件

```
- job_name: 'blackbox_http_2xx_post'
  scrape_interval: 10s
  metrics_path: /probe
  params:
    module: [http_post_2xx]   #对应blackbox模块名字
  static_configs:
      - targets:
        - 172.30.81.194:8080   # 对应测试目标地址
        labels:
          group: 'Interface monitoring'
  relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 172.30.81.192:9115  # blackbox的地址
```

## 3. prometheus 检查是否成功

`probe_success`
