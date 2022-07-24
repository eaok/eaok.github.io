



启动grafana

```shell
docker run -d -p 3000:3000 --name grafana grafana/grafana
```

启动promethus

```shell
docker run -d -p 9090:9090 --name prometheus -v /home/tahr/go-gin-api/deploy/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
```

