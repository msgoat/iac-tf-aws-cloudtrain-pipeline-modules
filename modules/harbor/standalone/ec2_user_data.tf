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

echo "marking data volumes as mounted"
echo "DO NOT DELETE OR RENAME THIS FILE!" > $HARBOR_DATA_VOLUME_MARKER

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

echo "start harbor service"
docker compose -f $HARBOR_BIN_HOME/docker-compose.yml up -d
EOT
}

data aws_secretsmanager_secret_version postgres {
  secret_id = module.postgresql.db_secret_id
}
