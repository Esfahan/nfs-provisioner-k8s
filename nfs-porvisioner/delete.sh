#!/bin/bash
DIRNAME=$(cd "$(dirname "$0")"; pwd)
BUILD_DIRNAME="${DIRNAME}/build"

set -x

usage() {
    cat << EOF
  usage: $0 options
  OPTIONS:
    -h help
    -n Specify Namespace
EOF
    exit 1;
}

while getopts ":n:h" OPTION; do
  case ${OPTION} in
    n)
      NAMESPACE=${OPTARG};;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    h)
      usage
      exit 0
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

if [ -z "${NAMESPACE}" ]; then
  echo "Specify Namespace: -$NAMESPACE" >&2
  usage
  exit 1
fi

kubectl config set-context $(kubectl config current-context) --namespace=${NAMESPACE}

kubectl delete -f ${BUILD_DIRNAME}/deployment.yaml \
               -f ${BUILD_DIRNAME}/rbac.yaml \
               -f ${DIRNAME}/storage-class.yaml
