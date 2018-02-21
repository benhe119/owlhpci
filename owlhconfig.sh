#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
GREEN=$(tput setaf 3)
NORMAL=$(tput sgr0)

col=20

echo ""
echo "---------------------------------------"
echo "OwlH Suricata Event PCI-DSS Enrichement"
echo "---------------------------------------"
echo ""
echo "This script will modify logstash configuration file to include"
echo "suricata events PCI-DSS mapping enrichment."
echo "To complete the action we will restart logstash"
read -p "Do you want to continue [Y]/n?" -n 1 -r
if [[ $REPLY =~ ^[Nn]$ ]]
then
    echo ""
    echo "OwlH configuration aborted"
    echo ""
    exit 1
fi

printf '%-50s' "** Download template configuration file"
response=$( curl --write-out "%{http_code}\n" -so /tmp/config.sed "https://raw.githubusercontent.com/owlh/wazuhenrichment/master/config.sed")
if [[ ! $response == 200 ]] 
then
  printf '%s%*s%s\n' "$RED" $col "[ERROR]" "$NORMAL"
  echo "Error downloading template -> $response"
  exit 1
fi
printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"

printf '%-50s' "** Download PCI-DSS mapping file"
response=$( curl --write-out "%{http_code}\n" -so /tmp/pci_3.2.yaml "https://raw.githubusercontent.com/owlh/wazuhenrichment/master/pci_3.2.yaml")
if [[ ! $response == 200 ]] 
then
  printf '%s%*s%s\n' "$RED" $col "[ERROR]" "$NORMAL"
  echo "Error downloading PCI-DSS mapping-> $response"
  exit 1
fi
printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"

printf '%-50s' "** checking if 01-wazuh.conf file is in place"
if [ ! -f /etc/logstash/conf.d/01-wazuh.conf ]; then
    printf '%s%*s%s\n' "$RED" $col "[ERROR]" "$NORMAL"
    echo ">> Wazuh Logstash config file is not here!"
    echo ">> please, are you running logstash with wazuh config in this system"
    exit 1
fi
printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"

printf '%-50s' "** backup 01-wazuh.conf to 01-wazuh.conf.old"
{
  cp /etc/logstash/conf.d/01-wazuh.conf /etc/logstash/conf.d/01-wazuh.conf.old &> /dev/null
} || {
  printf '%s%*s%s\n' "$RED" $col "[ERROR]" "$NORMAL"
  exit 1
}
printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"


if [ ! -d "/etc/logstash/config/" ]; then
  printf '%-50s' "** folder /etc/logstash/config doesn't exists, creating..."
  {
    mkdir /etc/logstash/config/
  } || {
    printf '%s%*s%s\n' "$RED" $col "[ERROR]" "$NORMAL"
    exit 1
  }
  printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"
fi

printf '%-50s' "** Copy PCI-DSS mapping file to config folder"
{
  cp /tmp/PCI_DSS.3.2.yaml /etc/logstash/config/.
} || {
  printf '%s%*s%s\n' "$RED" $col "[ERROR]" "$NORMAL"
  exit 1
}
printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"

printf '%-50s' "** configuring 01-wazuh.conf"
{
  sed -i -f config.sed /etc/logstash/conf.d/01-wazuh.conf &> /dev/null
} || {
  printf '%s%*s%s\n' "$RED" $col "[ERROR]" "$NORMAL"
  exit 1
}
printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"

printf '%-50s' "** restarting logstash"
{
  systemctl restart logstash &> /dev/null
} || {
  printf '%s%*s%s\n' "$RED" $col "[ERROR]" "$NORMAL"
  exit 1
}
printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"
