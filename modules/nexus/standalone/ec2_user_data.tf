locals {
  ec2_user_data = <<EOT
#!/bin/bash
# on_cloud_init.sh
# ----------------------------------------------------------------------------
# This script is passed as user data during EC2 launch and executed
# when the EC2 instance is booted for the first time.
# Since all user data scripts are executed as root there's not need for sudo
# ----------------------------------------------------------------------------
set -eux

export SONATYPE_HOME=/opt/sonatype
export NEXUS_HOME=$SONATYPE_HOME/nexus3
export NEXUS_DATA_ON_ROOT=$SONATYPE_HOME/sonatype-work/nexus3
export NEXUS_DATA_ON_DATA=/data/sonatype-work/nexus3
export NEXUS_DATA_VOLUME_MARKER=/data/.nexus_data_volume
export NEXUS_ROOT_VOLUME_MARKER=$SONATYPE_HOME/nexus3/.nexus_root_volume

mountDataVolume() {

  DATA_BLOCK_DEVICE=/dev/nvme1n1
  echo '*** Mounting Nexus data volume ***'

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

reconfigureNexus() {

  mkdir -p $NEXUS_DATA_ON_DATA

  echo "Move nexus workdir to newly attached data volume"
  if [[ -e "$NEXUS_DATA_ON_DATA/log" ]]
  then
    echo "Nexus workdir already exists on data volume"
  else
    echo "Moving nexus workdir to newly attached data volume"
    mv $NEXUS_DATA_ON_ROOT $NEXUS_DATA_ON_DATA/
    chown -R nexus:nexus $NEXUS_DATA_ON_DATA
  fi
  ls -al $NEXUS_DATA_ON_DATA

  echo "Switch nexus configuration to newly attached data volume"
  cp -f $SONATYPE_HOME/.local/nexus/nexus.vmoptions.data_volume $NEXUS_HOME/bin/nexus.vmoptions
  cat $NEXUS_HOME/bin/nexus.vmoptions
}

echo "Stop nexus service"
systemctl stop nexus

echo "Check if nexus data volume is already mounted"
if [ -e "$NEXUS_DATA_VOLUME_MARKER" ]
then
  echo '*** nexus data volume already mounted ***'
else
  mountDataVolume
  echo "Marking data volumes as mounted"
  echo "DO NOT DELETE OR RENAME THIS FILE\!" > $NEXUS_DATA_VOLUME_MARKER
fi

echo "Check if Nexus needs reconfiguration on root volume"
if [ -e "$NEXUS_ROOT_VOLUME_MARKER" ]
then
  echo '*** Nexus is already configured on root volume ***'
else
  reconfigureNexus
  echo "Marking root volumes reconfigured"
  echo "DO NOT DELETE OR RENAME THIS FILE\!" > $NEXUS_ROOT_VOLUME_MARKER
fi

echo "start nexus service"
systemctl start nexus
systemctl status -l nexus
EOT
}
