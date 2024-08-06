#cloud-config
# vim: syntax=yaml
#
# This is the cloud-init configuration

# Install packages
packages:
  - aliyun-cli
  - nfs-utils

# Download RDS cert bundle.
runcmd:
  - mkdir -p ${CERTS_MOUNT_PATH} ${TESTRUNS_MOUNT_PATH} ${BINARIES_MOUNT_PATH}
  - |
    echo "${REGION}.${TESTRUNS_EFS_ID}.efs.aliyuncs.com:/ \
    ${TESTRUNS_MOUNT_PATH} \
    nfs \
    ro,nfsvers=4,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" \
    >> /etc/fstab
  - |
    echo "${REGION}.${CERTS_EFS_ID}.efs.aliyuncs.com:/ \
    ${CERTS_MOUNT_PATH} \
    nfs \
    rw,nfsvers=4,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" \
    >> /etc/fstab
  - |
    echo "${REGION}.${BINARIES_EFS_ID}.efs.aliyuncs.com:/ \
    ${BINARIES_MOUNT_PATH} \
    nfs \
    nfsvers=4,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" \
    >> /etc/fstab
  - mount -a -t nfs
  - |
    aliyun ecs \
    AssociateEipAddress \
    --InstanceId "$(curl -s http://100.100.100.200/latest/meta-data/instance-id)" \
    --AllocationId ${EIP_ASSOCIATION_ID} \
    --RegionId ${REGION}
