# nfs-provisioner-k8s
- Installer of nfs-server
- Manifests for nfs-provisioner on Kubernetes

## Requirements
- CentOS 7.x

## Installation
### nfs-server
Define the following file for /etc/exports before executing `./nfs-server/nfs-installer.sh`.

```
$ cat nfs-server/files/exports
/var/share/nfs 192.168.1.0/24(rw,no_root_squash)
```

Execute the command below on nfs server.

```
$ sudo ./nfs-server/nfs-installer.sh
```

### For the client
Execute the command below on client server to mount dir on nfs-server.

```
$ sudo ./nfs-server/client.sh -n {hostname or ipaddr of nfs-server}
```

## Manifests of nfs-provisioner on Kubernetes
### Set hostname or ipaddr of nfs-server
Set hostname or ipaddr of nfs-server in ./nfs-provisionerg/deployment.yml

- NFS_SERVER on `spec.template.spec.containers.env`
- `spec.template.volumes.nfs.server`

### Create nfs-provisioner
Create nfs-provisioner on Kubernetes.

```
$ sudo ./nfs-provisionerg/apply.sh -n {NAMESPACE} -c {NFS_HOST}
```

### Delete nfs-provisioner
Delete nfs-provisioner on Kubernetes.

```
$ sudo ./nfs-provisionerg/delete.sh -n {NAMESPACE}
```


## PersistentVolumeClaim
This is a sample to use nfs-provisioner with PersistentVolumeClaim.

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  # Set your own name of PersistentVolumeClaim
  name: airflow-dags
  annotations:
    # Same as metadata.name in storage-class.yml
    volume.kubernetes.io/storage-class: "nfs"
spec:
  accessModes:
    - ReadWriteMany
  # Same as metadata.name in storage-class.yml
  storageClassName: nfs
  resources:
    requests:
      # Required size of volume
      storage: 2Gi
```
