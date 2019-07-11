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
    -c NFS HOST
EOF
    exit 1;
}

while getopts ":n:c:h" OPTION; do
  case ${OPTION} in
    n)
      NAMESPACE=${OPTARG};;
    c)
      NFS_HOST=${OPTARG};;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
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

if [ -z "${NFS_HOST}" ]; then
  echo "Specify NFS_HOST: -$NFS_HOST" >&2
  usage
  exit 1
fi

_UNAME_OUT=$(uname -s)
case "${_UNAME_OUT}" in
    Linux*)     _MY_OS=linux;;
    Darwin*)    _MY_OS=darwin;;
    *)          echo "${_UNAME_OUT} is unsupported."
                exit 1;;
esac
echo "Local OS is ${_MY_OS}"

case $_MY_OS in
  linux)
    SED_COMMAND=sed
  ;;
  darwin)
    SED_COMMAND=gsed
    if ! $(type "$SED_COMMAND" &> /dev/null) ; then
      echo "Could not find \"$SED_COMMAND\" binary, please install it. On OSX brew install gnu-sed" >&2
      exit 1
    fi
  ;;
  *)
    echo "${_UNAME_OUT} is unsupported."
    exit 1
  ;;
esac

kubectl create namespace ${NAMESPACE}
kubectl config set-context $(kubectl config current-context) --namespace=${NAMESPACE}

${SED_COMMAND} "s|{{NFS_HOST}}|${NFS_HOST}|g" ${DIRNAME}/deployment.yaml > ${BUILD_DIRNAME}/deployment.yaml
${SED_COMMAND} "s|{{NAMESPACE}}|${NAMESPACE}|g" ${DIRNAME}/rbac.yaml > ${BUILD_DIRNAME}/rbac.yaml

kubectl apply -f ${BUILD_DIRNAME}/deployment.yaml \
              -f ${BUILD_DIRNAME}/rbac.yaml \
              -f ${DIRNAME}/storage-class.yaml
