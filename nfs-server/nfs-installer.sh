#!/bin/bash
DIRNAME=$(cd "$(dirname "$0")"; pwd)

if [ ! -e "${DIRNAME}/files/exports" ]; then
  echo "You need to create ${DIRNAME}/files/exports"
  exit 1
fi

MOUNT_DIR=`cat ${DIRNAME}/files/exports | cut -d' ' -f1`

if [ -z "${MOUNT_DIR}" ]; then
  echo "${DIRNAME}/files/exports is invalid"
  exit 1
fi

set -x

sudo yum install rpcbind nfs-utils -y

sudo mkdir -p ${MOUNT_DIR}

EXPORTS_FILE='/etc/exports'
EXPORTS=`cat ${DIRNAME}/files/exports`

sudo cat ${EXPORTS_FILE} | grep -w "${EXPORTS}" > /dev/null 2>&1
if [ $? = 1 ]; then
  sudo echo "${EXPORTS}" >> ${EXPORTS_FILE}
  sudo exportfs -ra
else
  echo 'Alreday defined.'
fi

IDMAPD_FILE='/etc/idmapd.conf'
ORIGINAL='#Domain = local\.domain\.edu'
REPLACED='Domain = local\.domain\.edu'
sudo sed -i -e "s/${ORIGINAL}/${REPLACED}/g" ${IDMAPD_FILE}

sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
sudo systemctl enable nfs-server

# firewalld
RESULT=`ps -ef | grep firewalld | grep -v grep | wc -l`
if [ "$RESULT" != 0 ]; then
  sudo firewall-cmd --permanent --zone=public --add-service=nfs
  sudo firewall-cmd --reload
else
  echo 'FirewallD is not running'
fi
