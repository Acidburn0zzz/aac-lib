# aac-lib
AAC Library of Tools

Other Tools Include:

- <a href=https://github.com/Texiwill/aac-lib/tree/master/isolib>ISO Library Tool isolib.sh</a>
- <a href=https://github.com/Texiwill/aac-lib/tree/master/hooks>Git Pre-Commit Hook</a>

## ERK (Elasticsearch-Rsyslog-Kibana) Stack Installer

### Description
A bash script to automatically install an Elasticsearch-Rsyslog-Kibana
stack. Rsyslog replaces Logstash and allows direct forwarding of syslog
messages to Elasticsearch for other processing. I forward my LogInsight
logs to ERK for use with ElasticSearch.

Why did I create this script? Nothing I found on the web was as automated,
pulled the latest sources, and worked seamlessly with rsyslog.

> Reference: 
> 	http://www.havensys.net/making-a-free-log-server/

### Installation
Run the script using SUDO as root access is required. This allows Kibana to be wide open on your network. So first thing is to ensure proper firewall settings to limit access.

### Todo

- There is still security to add such as SSL Certificates + Credentials via Nginx
- Add Grafana support

### Support
Email elh at astroarch dot com for assistance or if you want to check
for more items.
