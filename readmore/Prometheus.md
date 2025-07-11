**Monitoring and Logging** are two foundational pillars of observability in modern IT infrastructure.

  * **Monitoring** (metrics-focused) provides real-time insights into system health and performance using numerical data (metrics) collected over time.
  * **Logging** (event-focused) captures detailed records of events, errors, and activities, crucial for debugging and post-mortem analysis.

**Prometheus** is a leading open-source monitoring system designed for reliability and scalability, making it a cornerstone for metrics collection and alerting in cloud-native environments.

-----

### 1\. Prometheus: Basics

**a. What is Prometheus?**
Prometheus is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. It is now a graduated project of the Cloud Native Computing Foundation (CNCF).

**Key Characteristics:**

  * **Time-Series Database (TSDB):** Stores all metrics as time series, identified by a metric name and key-value pairs (labels).
  * **Pull-based Model:** Prometheus actively "scrapes" (pulls) metrics from configured targets over HTTP at defined intervals.
  * **Powerful Query Language (PromQL):** Allows for flexible and precise querying and aggregation of time-series data.
  * **Alerting:** Can generate alerts based on PromQL queries and send them to an Alertmanager.
  * **Service Discovery:** Integrates with various service discovery mechanisms (e.g., Kubernetes, EC2, DNS) to automatically discover scraping targets.
  * **No Agent Required (on targets):** While exporters *run* on targets, they don't need to be tightly coupled agents; they simply expose an HTTP endpoint.

**b. Core Components:**

1.  **Prometheus Server:** The heart of the system.
      * **Scraper:** Discovers targets and scrapes (pulls) metrics from them.
      * **Time Series Database:** Stores collected metrics.
      * **PromQL Engine:** Processes queries against the stored data.
      * **Rule Manager:** Evaluates recording rules (for pre-aggregating data) and alerting rules.
2.  **Exporters:**
      * Lightweight agents that run on monitored systems (hosts, databases, applications).
      * They expose existing metrics or translate internal metrics into a Prometheus-readable format (HTTP endpoint, usually on port 9xxx).
      * Examples: Node Exporter (for Linux host metrics), cAdvisor (for Docker container metrics), MySQL Exporter, Blackbox Exporter.
3.  **Pushgateway (Optional):**
      * A component used for ephemeral or short-lived batch jobs that cannot be scraped directly by Prometheus.
      * These jobs push their metrics to the Pushgateway, and Prometheus then scrapes the Pushgateway.
4.  **Alertmanager:**
      * Receives alerts from the Prometheus server.
      * Handles deduplication, grouping, and routing of alerts to appropriate notification receivers (email, Slack, PagerDuty, etc.).
      * Manages silencing and inhibition of alerts.
5.  **Grafana:**
      * While not a Prometheus component, Grafana is the most common and powerful visualization tool used with Prometheus.
      * It connects to Prometheus as a data source and allows you to create rich, interactive dashboards using PromQL queries.

**c. Installation (Conceptual):**

1.  **Download:** Download the Prometheus server binary for your OS from the official website.
2.  **Configuration:** Create a `prometheus.yml` file. This is the main configuration file where you define scrape targets, rules, and more.
3.  **Run:** Start the Prometheus server binary, pointing to your configuration file.

-----

### 2\. Metrics and Exporters

**a. Metrics:**
Prometheus defines a specific data model for metrics, which are time-series data uniquely identified by a metric name and key-value pairs called **labels**.

  * **Labels:** Crucial for multi-dimensional data. They allow you to filter and aggregate metrics based on characteristics like instance, job, endpoint, status code, method, etc.
      * Example: `http_requests_total{method="GET", path="/api/users", status="200"}`
  * **Metric Types:**
      * **Counter:** A cumulative metric that only ever goes up. It represents a single monotonically increasing counter whose value can only be reset to zero on restart.
          * *Use case:* Total number of HTTP requests, total errors, bytes transferred.
          * *Example:* `http_requests_total`
      * **Gauge:** A single numerical value that can go up or down.
          * *Use case:* Current CPU utilization, memory usage, temperature, number of active connections.
          * *Example:* `node_cpu_usage_percentage`, `node_memory_MemFree_bytes`
      * **Histogram:** Samples observations (e.g., request durations, response sizes) and counts them in configurable buckets. It provides a sum of all observed values and a count of observations, allowing you to calculate averages and quantiles.
          * *Use case:* Request latency distribution (e.g., p99 latency).
          * *Example:* `http_request_duration_seconds_bucket`, `http_request_duration_seconds_sum`, `http_request_duration_seconds_count`
      * **Summary:** Similar to a histogram, it samples observations but calculates configurable quantiles over a sliding time window on the client side. More resource-intensive for the target application.

**b. Exporters:**
Exporters bridge the gap between Prometheus and systems that don't natively expose metrics in the Prometheus format. They scrape metrics from these systems and expose them over an HTTP endpoint for Prometheus to pull.

  * **Common Exporters:**

      * **Node Exporter:** Collects comprehensive system-level metrics from Linux/Unix hosts (CPU, memory, disk I/O, network I/O, filesystem usage, etc.).
      * **cAdvisor:** Gathers resource usage and performance metrics from running Docker containers and Kubernetes.
      * **Blackbox Exporter:** Probes network endpoints (HTTP, HTTPS, DNS, TCP, ICMP) to check their availability and latency from Prometheus's perspective (external monitoring).
      * **Database Exporters:** Specific exporters for databases like MySQL, PostgreSQL, MongoDB, etc.
      * **Cloud Exporters:** For cloud-specific services (e.g., `aws_exporter`).
      * **Application Client Libraries:** For instrumenting your own applications (Go, Java, Python, Ruby, Node.js, etc.) to directly expose custom metrics.

  * **Example `prometheus.yml` with Exporters:**

    ```yaml
    global:
      scrape_interval: 15s # How frequently to scrape targets

    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090'] # Prometheus scrapes itself

      - job_name: 'node_exporter'
        static_configs:
          - targets: ['192.168.1.100:9100', '192.168.1.101:9100'] # IP and default port for Node Exporter

      - job_name: 'blackbox'
        metrics_path: /probe
        params:
          module: [http_2xx] # Use the http_2xx module from blackbox.yml
        static_configs:
          - targets:
              - 'https://example.com'
              - 'https://api.example.com'
        relabel_configs:
          - source_labels: [__address__]
            target_label: __param_target
          - source_labels: [__param_target]
            target_label: instance
          - target_label: __address__
            replacement: 127.0.0.1:9115 # Blackbox Exporter's address
    ```

-----

### 3\. PromQL (Prometheus Query Language)

**PromQL** is Prometheus's powerful, functional query language. It allows you to select, filter, aggregate, and transform time-series data into meaningful insights.

**a. Key Concepts:**

  * **Metric Selectors:** Select time series based on metric name and labels.
      * `http_requests_total` (all series for this metric)
      * `http_requests_total{method="GET"}` (series where method is GET)
      * `http_requests_total{status=~"5.."}` (series where status code starts with 5)
  * **Instant Vector vs. Range Vector:**
      * **Instant Vector:** A set of time series containing a single sample for each series, all sharing the same timestamp (the query evaluation time).
          * Example: `node_cpu_seconds_total` (current CPU total seconds).
      * **Range Vector:** A set of time series containing a range of samples over a specified time duration, for each series. Used for functions like `rate()`, `increase()`.
          * Example: `http_requests_total[5m]` (all samples for this metric over the last 5 minutes).
  * **Operators:**
      * **Arithmetic:** `+`, `-`, `*`, `/`, `%`, `^`
      * **Comparison:** `==`, `!=`, `<`, `>`, `<=`, `>=`
      * **Logical/Set:** `and`, `or`, `unless`
      * **Vector Matching:** How operations between two instant vectors align (e.g., `on`, `ignoring` labels).
  * **Aggregation Operators:** Combine results from multiple time series.
      * `sum()`, `avg()`, `count()`, `min()`, `max()`, `stddev()`, `stdvar()`, `quantile()`
      * Used with `by (<label1>, ...)` or `without (<label1>, ...)` to group results.
  * **Functions:** Perform calculations or transformations on vectors.
      * `rate(range_vector)`: Calculates the per-second average rate of increase of a counter over a time range.
      * `irate(range_vector)`: Calculates the *instantaneous* per-second rate of increase of a counter.
      * `increase(range_vector)`: Calculates the total increase of a counter over a time range.
      * `delta(range_vector)`: Calculates the difference between the first and last value of a gauge.
      * `histogram_quantile(quantile, histogram_bucket_metric)`: Calculates quantiles from a histogram metric.

**b. Common PromQL Examples:**

  * **Current CPU Usage (percentage):**
    ```promql
    100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
    ```
  * **HTTP Requests Per Second (RPS):**
    ```promql
    rate(http_requests_total[5m])
    ```
    *This gets the average rate of requests over the last 5 minutes.*
  * **Error Rate (as a percentage of total requests):**
    ```promql
    sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100
    ```
    *This calculates the percentage of 5xx errors out of all HTTP requests.*
  * **99th Percentile Latency (from a Histogram):**
    ```promql
    histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))
    ```
  * **Available Memory in GB:**
    ```promql
    node_memory_MemAvailable_bytes / (1024 * 1024 * 1024)
    ```
  * **Network Interface Bytes Received (rate):**
    ```promql
    rate(node_network_receive_bytes_total[1m])
    ```

-----

### 4\. Alerting

Prometheus integrates with **Alertmanager** for flexible and robust alert handling.

**a. How it Works:**

1.  **Alerting Rules:** Defined in Prometheus's configuration (`prometheus.yml` or separate rule files). These rules contain PromQL expressions that, when true for a specified duration, trigger an alert.
2.  **Prometheus Evaluation:** The Prometheus server periodically evaluates these rules. If an alert condition is met, Prometheus sends the alert to the configured Alertmanager instance.
3.  **Alertmanager Processing:** Alertmanager receives the alert and then:
      * **Deduplicates:** Prevents sending multiple identical notifications.
      * **Groups:** Groups similar alerts into a single notification to avoid alert storms (e.g., if 10 servers are down, send one "10 Servers Down" alert).
      * **Routes:** Sends notifications to specific receivers based on alert labels (e.g., critical alerts to PagerDuty, warnings to Slack).
      * **Silences:** Allows you to temporarily mute alerts for planned maintenance.
      * **Inhibition:** Suppresses lower-priority alerts if a higher-priority, related alert is already firing (e.g., don't alert on high CPU if the entire server is offline).

**b. Alerting Rule Example (`alert.rules.yml`):**

```yaml
# rules/app_alerts.yml (referenced in prometheus.yml)

groups:
  - name: application-alerts
    rules:
      - alert: HighErrorRate
        expr: (sum(rate(http_requests_total{status=~"5.."}[5m])) by (job, instance) / sum(rate(http_requests_total[5m])) by (job, instance)) * 100 > 5
        for: 2m # Stay true for 2 minutes before firing
        labels:
          severity: critical
        annotations:
          summary: "High 5xx error rate on {{ $labels.instance }}"
          description: "The 5xx error rate on instance {{ $labels.instance }} is above 5% for 2 minutes."

      - alert: InstanceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} is down"
          description: "Instance {{ $labels.instance }} (job {{ $labels.job }}) has been unreachable for 1 minute."
```

  * **`alert`**: The name of the alert.
  * **`expr`**: The PromQL expression that defines the alert condition.
  * **`for`**: How long the expression must be true before the alert fires.
  * **`labels`**: Additional labels attached to the alert (used by Alertmanager for routing/grouping).
  * **`annotations`**: Descriptive information about the alert, often included in the notification. `{{ $labels.<label_name> }}` can be used for templating.

**c. Alertmanager Configuration (`alertmanager.yml`):**

```yaml
# alertmanager.yml

global:
  resolve_timeout: 5m # After this time, alerts are considered resolved

route:
  receiver: 'default-receiver' # Default receiver for all alerts
  group_by: ['alertname', 'cluster', 'service'] # Group similar alerts
  group_wait: 30s # Wait before sending first notification for a new group
  group_interval: 5m # Wait before sending subsequent notifications for a group
  repeat_interval: 3h # Re-send notification if alert persists

  routes:
    - match:
        severity: 'critical'
      receiver: 'pagerduty-receiver'
      continue: true # Continue evaluating other routes
    - match:
        severity: 'warning'
      receiver: 'slack-receiver'
    - match:
        environment: 'dev'
      receiver: 'dev-team-slack'

receivers:
  - name: 'default-receiver'
    webhook_configs:
      - url: 'http://my-custom-webhook-receiver/alerts'
  - name: 'pagerduty-receiver'
    pagerduty_configs:
      - service_key: 'YOUR_PAGERDUTY_SERVICE_KEY'
  - name: 'slack-receiver'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
        channel: '#alerts-general'
        text: '{{ .CommonAnnotations.summary }}'
  - name: 'dev-team-slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/OTHER/SLACK/WEBHOOK'
        channel: '#alerts-dev'
```

Prometheus provides a robust and flexible monitoring solution, particularly well-suited for dynamic cloud-native environments, enabling precise querying, effective alerting, and clear visualization when combined with tools like Grafana.