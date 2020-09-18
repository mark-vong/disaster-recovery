// Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

/*
 * Create an server instance
 */

provider oci {
  alias = "destination"
}

resource oci_core_instance "private_server" {
  provider            = oci.destination
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = var.display_name

  source_details {
    source_type = "image"
    source_id   = var.source_id
  }

  agent_config {
    is_management_disabled = true
    is_monitoring_disabled = true
  }

  shape = var.shape

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    # user_data           = var.user_data
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = false

    nsg_ids = [
      var.ping_all_id
    ]
  }

  connection {
    type        = "ssh"
    host        = oci_core_instance.private_server.private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key_file)

    bastion_host        = var.bastion_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.ssh_private_key_file)
  }
}

/*
 * Provision Block Storage
 */
resource "oci_core_volume" "volume1" {
  provider            = oci.destination

  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = join("-",[var.display_name, "volume"])
  size_in_gbs         = "${var.Size}"
}

resource "oci_core_volume_attachment" "attachment1" {
  provider            = oci.destination

  attachment_type = "iscsi"
  instance_id     = "${oci_core_instance.private_server.id}"
  volume_id       = "${oci_core_volume.volume1.id}"

  connection {
    type        = "ssh"
    host        = oci_core_instance.private_server.private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key_file)

    bastion_host        = var.bastion_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.ssh_private_key_file)
  }

# register and connect the iSCSI block volume
  provisioner "remote-exec" {
    inline = [
      "sudo iscsiadm -m node -o new -T ${self.iqn} -p ${self.ipv4}:${self.port}",
      "sudo iscsiadm -m node -o update -T ${self.iqn} -n node.startup -v automatic",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -l",
    ]
  }

# initialize partition and file system
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-1",
      "export HAS_PARTITION=$(sudo partprobe -d -s /dev/disk/by-path/$${DEVICE_ID} | wc -l)",
      "if [ $HAS_PARTITION -eq 0 ] ; then",
      "  (echo g; echo n; echo ''; echo ''; echo ''; echo w) | sudo fdisk /dev/disk/by-path/$${DEVICE_ID}",
      "  while [[ ! -e /dev/disk/by-path/$${DEVICE_ID}-part1 ]] ; do sleep 1; done",
      "  sudo mkfs.xfs /dev/disk/by-path/$${DEVICE_ID}-part1",
      "fi",
    ]
}

# mount the partition
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-1",
      "sudo mkdir -p /mnt/vol1",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
      "echo 'UUID='$${UUID}' /mnt/vol1 xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
    ]
}

# unmount and disconnect on destroy
  provisioner "remote-exec" {
    when       = destroy
    on_failure = continue
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-1",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
      "sudo umount /mnt/vol1",
      "if [[ $UUID ]] ; then",
      "  sudo sed -i.bak '\\@^UUID='$${UUID}'@d' /etc/fstab",
      "fi",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -u",
      "sudo iscsiadm -m node -o delete -T ${self.iqn} -p ${self.ipv4}:${self.port}",
    ]
  }

  # deploy application
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "sudo firewall-cmd --add-service=http --permanent",
      "sudo systemctl restart firewalld",
      "sudo systemctl enable firewalld",
      "sudo yum install httpd -y",
      "sudo sed -i 's|</Directory>|</Directory>\\n<Directory /mnt/vol1/images>\\n\\tAllowOverride All\\n\\tAllow from all\\n\\tRequire all granted\\n</Directory>\\n|' /etc/httpd/conf/httpd.conf",
      "sudo sed -i 's|<IfModule alias_module>|<IfModule alias_module>\\nAlias /admin /mnt/vol1/images\\n|' /etc/httpd/conf/httpd.conf",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
      "sudo mkdir -p /mnt/vol1/images",
      "sudo chmod 777 /mnt/vol1/images",
      "sudo chcon -R --type=httpd_sys_rw_content_t /mnt/vol1/images/",
      "echo $'<html>\n\t<body>\n\t\t<h2>Welcome to Oracle Cloud</h2>\n\t\t<embed src=\"/admin/oracle.png\" />\n\t</body>\n</html>' | sudo tee /var/www/html/index.html",
    ]
  }

  # copy image file to remote host
  provisioner "file" {
    source = "./assets/images/oracle.png"
    destination = "/mnt/vol1/images/oracle.png"
  }
}