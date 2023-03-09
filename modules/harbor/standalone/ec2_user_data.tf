locals {
  postgres_secret_value = jsondecode(data.aws_secretsmanager_secret_version.postgres.secret_string)
  ec2_user_data = <<EOT
#!/bin/bash
# on_cloud_init.sh
# ----------------------------------------------------------------------------
# This script is passed as user data during EC2 launch and executed
# when the EC2 instance is booted for the first time.
# Since all user data scripts are executed as root there's not need for sudo
# ----------------------------------------------------------------------------
set -eu

export HARBOR_HOME=/opt/harbor
export HARBOR_BIN_HOME=$HARBOR_HOME/bin
export HARBOR_DATA_ON_ROOT=$HARBOR_HOME/data
export HARBOR_DATA_ON_DATA=/data/harbor
export HARBOR_DATA_VOLUME_MARKER=/data/.harbor_data_volume
export HARBOR_ROOT_VOLUME_MARKER=$HARBOR_HOME/.harbor_root_volume

mountDataVolume() {

  DATA_BLOCK_DEVICE=/dev/nvme1n1
  echo '*** Mounting harbor data volume ***'

  echo "Wait for data volume to be attached"
  while [[ "$(lsblk -f $DATA_BLOCK_DEVICE -o FSTYPE -n)" == *"no block device"* ]]
  do
    sleep 1
  done

  echo "Check if filesystem xfs is on data volume"
  if [[ "$(lsblk -f $DATA_BLOCK_DEVICE -o FSTYPE -n)" == "xfs" ]]
  then
    echo "filesystem xfs is already on data volume"
  else
    echo "creating filesystem xfs on data volume"
    mkfs -t xfs $DATA_BLOCK_DEVICE
  fi

  echo "mount data volume at /data"
  mkdir /data
  echo "UUID=$(blkid -s UUID -o value $DATA_BLOCK_DEVICE)  /data  xfs  defaults,nofail  0  2" | sudo tee /etc/fstab -a
  mount -a
  mount | grep '/data'
  ls -al /data
}

reconfigureHarbor() {

  echo "move harbor workdir to newly attached data volume"
  mkdir -p $HARBOR_DATA_ON_DATA
  if [ -e "$HARBOR_DATA_ON_ROOT" ]
  then
    mv $HARBOR_DATA_ON_ROOT $HARBOR_DATA_ON_DATA/
  fi

  chown -R harbor:harbor $HARBOR_DATA_ON_DATA
  ls -al $HARBOR_DATA_ON_DATA

  echo "re-configure harbor to newly attached data volume and other attached resources"
  rm -f $HARBOR_BIN_HOME/harbor.yml
  export HARBOR_HOST_NAME=docker.cloudtrain.aws.msgoat.eu
  export HARBOR_EXTERNAL_URL=https://$HARBOR_HOST_NAME
  export HARBOR_DATA_VOLUME=$HARBOR_DATA_ON_DATA
  export HARBOR_LOG_LOCAL_LOCATION=$HARBOR_DATA_VOLUME/log/harbor
  export HARBOR_POSTGRES_HOST=${module.postgresql.db_host_name}
  export HARBOR_POSTGRES_PORT=${module.postgresql.db_port_number}
  export HARBOR_POSTGRES_NAME=registry
  export HARBOR_POSTGRES_USERNAME=${local.postgres_secret_value["postgresql-user"]}
  export HARBOR_POSTGRES_PASSWORD='${local.postgres_secret_value["postgresql-password"]}'
  export HARBOR_STORAGE_S3_ACCESS_KEY=${aws_iam_access_key.harbor.id}
  export HARBOR_STORAGE_S3_SECRET_KEY='${aws_iam_access_key.harbor.secret}'
  export HARBOR_STORAGE_S3_REGION=${var.region_name}
  export HARBOR_STORAGE_S3_BUCKET_NAME=${module.s3_bucket.s3_bucket_name}
  envsubst </tmp/harbor.yml >$HARBOR_BIN_HOME/harbor.yml
  chown harbor:harbor $HARBOR_BIN_HOME/harbor.yml
  cd $HARBOR_BIN_HOME
  ./install.sh --with-trivy
  chown harbor:harbor -R $HARBOR_BIN_HOME
  chmod a+r -R $HARBOR_BIN_HOME
}

echo "Stop harbor service"
docker compose -f $HARBOR_BIN_HOME/docker-compose.yml down -v

echo "Check if harbor data volume is already mounted"
if [ -e "$HARBOR_DATA_VOLUME_MARKER" ]
then
  echo '*** harbor data volume already mounted ***'
else
  mountDataVolume
  echo "Marking data volumes as mounted"
  echo "DO NOT DELETE OR RENAME THIS FILE\!" > $HARBOR_DATA_VOLUME_MARKER
fi

echo "Check if Harbor needs reconfiguration on root volume"
if [ -e "$HARBOR_ROOT_VOLUME_MARKER" ]
then
  echo '*** harbor is already configured on root volume ***'
else
  reconfigureHarbor
  echo "Marking root volumes reconfigured"
  echo "DO NOT DELETE OR RENAME THIS FILE\!" > $HARBOR_ROOT_VOLUME_MARKER
fi

echo "Start harbor service"
docker compose -f $HARBOR_BIN_HOME/docker-compose.yml up -d
docker compose -f $HARBOR_BIN_HOME/docker-compose.yml ps
EOT
}

data aws_secretsmanager_secret_version postgres {
  secret_id = module.postgresql.db_secret_id
}
