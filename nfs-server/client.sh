#!/bin/bash
function usage {
  cat <<EOM
Usage: $(basename "$0") [OPTION]...
  -h          Display help
  -n VALUE    hostname or ipaddr of nfs-server
EOM

  exit 2
}

while getopts ":n:h" optKey; do
  case "$optKey" in
    n)
      NFS_SERVER=${OPTARG}
      ;;
    '-h'|'--help'|* )
      usage
      ;;
  esac
done

set -x

if [ -z "$NFS_SERVER" ]; then
  echo 'Specify host or ipaddr of nfs-server as the first argument'
  exit 1
fi

REMOTE_VOLUME='/var/share/nfs'
LOCAL_VOLUME='/mnt/nfs'

sudo yum install rpcbind nfs-utils -y
sudo mount -t nfs ${NFS_SERVER}:${REMOTE_VOLUME} ${LOCAL_VOLUME}
