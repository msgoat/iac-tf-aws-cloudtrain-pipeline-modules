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

export SONARQUBE_HOME=/opt/sonarqube
export SONARQUBE_BIN_HOME=$SONARQUBE_HOME
export SONARQUBE_DATA_ON_ROOT=$SONARQUBE_HOME
export SONARQUBE_DATA_ON_DATA=/data/sonarqube
export SONARQUBE_DATA_VOLUME_MARKER=/data/.sonarqube_data_volume
export SONARQUBE_ROOT_VOLUME_MARKER=$SONARQUBE_HOME/.sonarqube_root_volume

mountDataVolume() {

  DATA_BLOCK_DEVICE=/dev/nvme1n1
  echo '*** Mounting sonarqube data volume ***'

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

reconfigureSonarqube() {

  echo "move sonarqube workdir to newly attached data volume"
  mkdir -p $SONARQUBE_DATA_ON_DATA
  if [ ! -e "$SONARQUBE_DATA_ON_DATA/data" ]
  then
    mv $SONARQUBE_DATA_ON_ROOT/data $SONARQUBE_DATA_ON_DATA/data
  fi
  if [ ! -e "$SONARQUBE_DATA_ON_DATA/logs" ]
  then
    mv $SONARQUBE_DATA_ON_ROOT/logs $SONARQUBE_DATA_ON_DATA/logs
  fi
  if [ ! -e "$SONARQUBE_DATA_ON_DATA/temp" ]
  then
    mv $SONARQUBE_DATA_ON_ROOT/temp $SONARQUBE_DATA_ON_DATA/temp
  fi

  chown -R sonarqube:sonarqube $SONARQUBE_DATA_ON_DATA
  ls -al $SONARQUBE_DATA_ON_DATA

  echo "re-configure sonarqube to newly attached data volume and other attached resources"
  rm -f $SONARQUBE_BIN_HOME/conf/sonar.properties
  export SONARQUBE_PATH_DATA=$SONARQUBE_DATA_ON_DATA/data
  export SONARQUBE_PATH_LOGS=$SONARQUBE_DATA_ON_DATA/logs
  export SONARQUBE_PATH_TEMP=$SONARQUBE_DATA_ON_DATA/temp
  export SONARQUBE_POSTGRES_HOST=${module.postgresql.db_host_name}
  export SONARQUBE_POSTGRES_PORT=${module.postgresql.db_port_number}
  export SONARQUBE_POSTGRES_USERNAME=${local.postgres_secret_value["postgresql-user"]}
  export SONARQUBE_POSTGRES_PASSWORD='${local.postgres_secret_value["postgresql-password"]}'
  envsubst </tmp/sonar.tpl.properties >/tmp/sonar.properties
  mv /tmp/sonar.properties $SONARQUBE_BIN_HOME/conf/sonar.properties
  chown sonarqube:sonarqube $SONARQUBE_BIN_HOME/conf/sonar.properties
  chown sonarqube:sonarqube -R $SONARQUBE_DATA_ON_DATA
  chmod a+r -R $SONARQUBE_BIN_HOME
}

echo "Stop sonarqube service"
systemctl stop sonarqube

echo "Check if sonarqube data volume is already mounted"
if [ -e "$SONARQUBE_DATA_VOLUME_MARKER" ]
then
  echo '*** sonarqube data volume already mounted ***'
else
  mountDataVolume
  echo "Marking data volumes as mounted"
  echo "DO NOT DELETE OR RENAME THIS FILE\!" > $SONARQUBE_DATA_VOLUME_MARKER
fi

echo "Check if Sonarqube needs reconfiguration on root volume"
if [ -e "$SONARQUBE_ROOT_VOLUME_MARKER" ]
then
  echo '*** sonarqube is already configured on root volume ***'
else
  reconfigureSonarqube
  echo "Marking root volumes reconfigured"
  echo "DO NOT DELETE OR RENAME THIS FILE\!" > $SONARQUBE_ROOT_VOLUME_MARKER
fi

echo "Start sonarqube service"
systemctl enable sonarqube
systemctl start sonarqube
systemctl status sonarqube
EOT
}

data aws_secretsmanager_secret_version postgres {
  secret_id = module.postgresql.db_secret_id
}
