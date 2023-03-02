locals {
  ec2_user_data = <<EOT
#!/bin/bash
# on_cloud_init.sh
# ----------------------------------------------------------------------------
# This script is passed as user data during EC2 launch and executed
# when the EC2 instance is booted for the first time.
# Since all user data scripts are executed as root there's not need for sudo
# ----------------------------------------------------------------------------
set -eu

export DATA_BLOCK_DEVICE=/dev/nvme1n1
export HARBOR_HOME=/opt/harbor
export HARBOR_BIN_HOME=$HARBOR_HOME/bin
export HARBOR_DATA_ON_ROOT=$HARBOR_HOME/data
export HARBOR_DATA_ON_DATA=/data/harbor
export HARBOR_DATA_VOLUME_MARKER=$HARBOR_DATA_ON_DATA/.harbor_data_volume

echo 'check if harbor data volume is already mounted'
if [ -e "$HARBOR_DATA_VOLUME_MARKER" ]
then
  echo '*** harbor data volume already mounted ***'
  exit 0
fi

echo '*** mounting harbor data volume ***'

echo 'stop harbor service'
docker compose -f $HARBOR_BIN_HOME/docker-compose.yml down

echo 'get info about all attached block devices'
lsblk -f

echo 'install filesystem xfs on data volume'
file -s $DATA_BLOCK_DEVICE
mkfs -t xfs $DATA_BLOCK_DEVICE
file -s $DATA_BLOCK_DEVICE

echo 'mount data volume at /data'
mkdir /data
echo "UUID=$(sudo blkid -s UUID -o value $DATA_BLOCK_DEVICE)  /data  xfs  defaults,nofail  0  2" | sudo tee /etc/fstab -a
mount -a
mount | grep '/data'
ls -al /data

echo "move harbor workdir to newly attached data volume"
mkdir -p $HARBOR_DATA_ON_DATA
mv $HARBOR_DATA_ON_ROOT $HARBOR_DATA_ON_DATA/
chown -R harbor:harbor $HARBOR_DATA_ON_DATA
ls -al $HARBOR_DATA_ON_DATA

echo "re-configure harbor to newly attached data volume"

echo "Setup configuration file for habor prepare"
export HARBOR_HOST_NAME=docker.cloudtrain.aws.msgoat.eu
export HARBOR_EXTERNAL_URL=https://$HARBOR_HOST_NAME
export HARBOR_DATA_VOLUME=$HARBOR_DATA_ON_DATA
export HARBOR_LOG_LOCAL_LOCATION=$HARBOR_DATA_VOLUME/log/harbor
envsubst </tmp/harbor.yml >$HARBOR_BIN_HOME/harbor.yml
chown harbor:harbor $HARBOR_BIN_HOME/harbor.yml

echo "marking data volumes as mounted"
echo "DO NOT DELETE OR RENAME THIS FILE!" > $HARBOR_DATA_VOLUME_MARKER

echo "start harbor service"
docker compose -f $HARBOR_BIN_HOME/docker-compose.yml up -d
EOT
}
