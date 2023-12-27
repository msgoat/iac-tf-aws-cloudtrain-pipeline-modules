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

export TRAEFIK_HOME=/opt/traefik
export TRAEFIK_BIN_HOME=$TRAEFIK_HOME
export TRAEFIK_DATA_ON_ROOT=$TRAEFIK_HOME/data
export TRAEFIK_DATA_ON_DATA=/data/traefik
export TRAEFIK_DATA_VOLUME_MARKER=$TRAEFIK_DATA_ON_DATA/.traefik_data_volume
export TRAEFIK_ROOT_VOLUME_MARKER=$TRAEFIK_BIN_HOME/.traefik_root_volume

mountDataVolume() {

  DATA_BLOCK_DEVICE_NAME=nvme1n1
  DATA_BLOCK_DEVICE=/dev/$DATA_BLOCK_DEVICE_NAME

  echo '*** Mounting Traefik data volume ***'

  echo "Check if data volume is attached"
  while [ "$(lsblk -o NAME | grep $DATA_BLOCK_DEVICE_NAME)" != "$DATA_BLOCK_DEVICE_NAME" ]
  do
    echo "Waiting for block device $DATA_BLOCK_DEVICE_NAME to be attached"
    sleep 1
  done

  echo "Check if filesystem xfs is already present on data volume"
  if [ "$(lsblk -f $DATA_BLOCK_DEVICE -o FSTYPE -n)" == "xfs" ]
  then
    echo "Filesystem xfs is already present on data volume"
  else
    echo "Creating filesystem xfs on data volume"
    mkfs -t xfs $DATA_BLOCK_DEVICE
  fi

  echo "Mount data volume at /data"
  mkdir /data
  echo "UUID=$(blkid -s UUID -o value $DATA_BLOCK_DEVICE)  /data  xfs  defaults,nofail  0  2" | sudo tee /etc/fstab -a
  mount -a
  mount | grep '/data'
  ls -al /data
}

reconfigureTraefik () {

  echo "Moving Traefik workdir to newly attached data volume"
  mkdir -p $TRAEFIK_DATA_ON_DATA
  cp -nR $TRAEFIK_DATA_ON_ROOT/* $TRAEFIK_DATA_ON_DATA/

  echo "Re-generating traefik static configuration"
  rm -rf $TRAEFIK_DATA_ON_DATA/config/traefik.yml
  export TRAEFIK_DATA=$TRAEFIK_DATA_ON_DATA
  envsubst <$TRAEFIK_BIN_HOME/tpl/traefik.tpl.yml >$TRAEFIK_DATA_ON_DATA/config/traefik.yml

  echo "Copying traefik dynamic configuration from S3"
  rm -rf $TRAEFIK_DATA_ON_DATA/config/config.yml
  aws s3 cp s3://${var.s3_bucket_traefik_config}${var.s3_object_traefik_config} $TRAEFIK_DATA_ON_DATA/config/config.yml
  chown -R traefik:traefik $TRAEFIK_DATA_ON_DATA
  ls -al $TRAEFIK_DATA_ON_DATA

  echo "Re-generating Traefik service configuration"
  envsubst < $TRAEFIK_BIN_HOME/tpl/traefik.tpl.service > /etc/systemd/system/traefik.service
}

echo "Stopping Traefik service"
systemctl stop traefik

echo "Check if Traefik data volume is already mounted"
if [ -e "$TRAEFIK_DATA_VOLUME_MARKER" ]
then
  echo "*** traefik data volume already mounted ***"
else
  mountDataVolume
  echo "Marking data volumes as mounted"
  echo "DO NOT DELETE OR RENAME THIS FILE\!" > $TRAEFIK_DATA_VOLUME_MARKER
fi

echo "Check if Traefik needs reconfiguration on root volume"
if [ -e "$TRAEFIK_ROOT_VOLUME_MARKER" ]
then
  echo "*** traefik is already configured on root volume ***"
else
  reconfigureTraefik
  echo "Marking root volume reconfigured"
  echo "DO NOT DELETE OR RENAME THIS FILE\!" > $TRAEFIK_ROOT_VOLUME_MARKER
fi

echo "Starting Traefik service"
systemctl daemon-reload
systemctl start traefik
systemctl status -l traefik
EOT
}

output debug {
  value = local.ec2_user_data
}