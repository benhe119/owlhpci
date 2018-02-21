# OwlH integration with wazuh 
- Suricata events enrichment

This must be run in every Wazuh logstash server. It will: 

- Modify logstash configuration file
- Copy OwlH suricata PCI-DSS mapping to config folder
- Restart logstash


download configuration script

```
  curl -so /tmp/owlhconfig.sh https://raw.githubusercontent.com/owlh/wazuhenrichment/master/owlhconfig.sh
```

and then run it

```
  bash /tmp/owlhconfig.sh
```
