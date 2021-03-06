resource "null_resource" "master-provisioner" {
    triggers = {
        bastion-ip     = module.vm-jumpbox.ip[0]
        disk-devices   = join(
            ",",
            google_compute_attached_disk.datadisk-attach.*.device_name
        )
        firewall       = module.vm-master.self-link[0]
        nic-ip-address = module.vm-master.private-ip[0]
        vm-id          = module.vm-master.self-link[0]
        vm-keyfile     = file(var.server-jumpbox.keyfile)
        vm-user        = var.server-jumpbox.admin-user
    }

    connection {
        bastion_host = self.triggers.bastion-ip
        host         = self.triggers.nic-ip-address
        type         = "ssh"
        user         = self.triggers.vm-user
        private_key  = self.triggers.vm-keyfile
    }

    provisioner "file" {
        content = templatefile(
            "${path.module}/templates/bootstrap.sh",
            {
                disks = [for d in var.datadisk: {
                    device = format(
                        "/dev/sd%s",
                        substr("bcdefghij", index(var.datadisk, d), 1)
                    ),
                    mountpoint = d.mountpoint
                }]
            }
        )
        destination = "~/bootstrap.sh"
    }

    provisioner "remote-exec" {
        inline = [<<EOF
chmod +x ~/bootstrap.sh
sudo ~/bootstrap.sh
echo "Done.",
EOF
        ]
    }
}