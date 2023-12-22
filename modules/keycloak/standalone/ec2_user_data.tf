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
export KEYCLOAK_HOME=/opt/keycloak
export KEYCLOAK_BIN_HOME=$KEYCLOAK_HOME
export KEYCLOAK_DATA_ON_DATA=/data/keycloak
export KEYCLOAK_DATA_VOLUME_MARKER=$KEYCLOAK_DATA_ON_DATA/.keycloak_data_volume

mountDataVolume() {

  DATA_BLOCK_DEVICE_NAME=nvme1n1
  DATA_BLOCK_DEVICE=/dev/$DATA_BLOCK_DEVICE_NAME

  echo '*** Mounting keycloak data volume ***'

  echo "Check if data volume is attached"
  while [ "$(lsblk -o NAME | grep $DATA_BLOCK_DEVICE_NAME)" != "$DATA_BLOCK_DEVICE_NAME" ]
  do
    echo "Waiting for block device $DATA_BLOCK_DEVICE_NAME to be attached"
    sleep 1
  done

  echo "Check if filesystem xfs is on data volume"
  if [ "$(lsblk -f $DATA_BLOCK_DEVICE -o FSTYPE -n)" == "xfs" ]
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

  echo "Make sure keyclock data folder exists"
  mkdir -p $KEYCLOAK_DATA_ON_DATA
  ls -al $KEYCLOAK_DATA_ON_DATA
}

reconfigureKeycloak() {

  echo "Setting Keycloak admin via environment from AWS Secrets Manager secret"
  kc_secret=$(aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.keycloak.name} | jq '.SecretString' | jq fromjson)
  kc_admin_user=$(echo $kc_secret | jq -r '.["keycloak-user"]')
  kc_admin_password=$(echo $kc_secret | jq -r '.["keycloak-password"]')
  echo "export KEYCLOAK_ADMIN=$kc_admin_user" > /etc/profile.d/keycloak.sh
  echo "export KEYCLOAK_ADMIN_PASSWORD=$kc_admin_password" >> /etc/profile.d/keycloak.sh
  export KEYCLOAK_ADMIN=$kc_admin_user
  export KEYCLOAK_ADMIN_PASSWORD=$kc_admin_password
  chmod a+x /etc/profile.d/keycloak.sh

  echo "re-configure keycloak"
  rm -f $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  touch $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  pg_secret=$(aws secretsmanager get-secret-value --secret-id ${module.postgresql.db_secret_name} | jq '.SecretString' | jq fromjson)
  pg_user=$(echo $pg_secret | jq -r '.["postgresql-user"]')
  pg_password=$(echo $pg_secret | jq -r '.["postgresql-password"]')
  pg_endpoint=$(aws rds describe-db-instances --db-instance-identifier ${module.postgresql.db_instance_id} | jq '.DBInstances[0].Endpoint')
  pg_endpoint_host=$(echo $pg_endpoint | jq -r '.["Address"]')
  pg_endpoint_port=$(echo $pg_endpoint | jq -r '.["Port"]')
  echo "db=postgres" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  echo "db-username=$pg_user" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  echo "db-password=$pg_password" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  echo "db-url-host=$pg_endpoint_host" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  echo "db-url-port=$pg_endpoint_port" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  echo "db-url-database=keycloak" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  echo "hostname=oidc.cloudtrain.aws.msgoat.eu" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  echo "hostname-strict-backchannel=true" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  echo "hostname-admin=oidc.cloudtrain.aws.msgoat.eu" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  echo "http-enabled=true" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  echo "health-enabled=true" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  echo "proxy=edge" >> $KEYCLOAK_BIN_HOME/conf/keycloak.conf
  chown keycloak:keycloak $KEYCLOAK_BIN_HOME/conf/keycloak.conf

  echo "optimize keycloak image"
  $KEYCLOAK_BIN_HOME/bin/kc.sh build --db=postgres

  echo "make sure user keycloak can access everything"
  chown -R keycloak:keycloak $KEYCLOAK_BIN_HOME
}

echo "Check if keycloak data volume is already mounted"
if [ -e "$KEYCLOAK_DATA_VOLUME_MARKER" ]
then
  echo '*** keycloak data volume already mounted ***'
else
  mountDataVolume
  echo "Marking data volumes as mounted"
  echo "DO NOT DELETE OR RENAME THIS FILE\!" > $KEYCLOAK_DATA_VOLUME_MARKER
fi

echo "Reconfigure keycloak"
reconfigureKeycloak

echo "Start keycloak service"
envsubst <$KEYCLOAK_HOME/tpl/keycloak.tpl.service >/etc/systemd/system/keycloak.service
systemctl daemon-reload
systemctl enable keycloak
systemctl start keycloak
systemctl status keycloak
EOT
}

data aws_secretsmanager_secret_version postgres {
  secret_id = module.postgresql.db_secret_id
}