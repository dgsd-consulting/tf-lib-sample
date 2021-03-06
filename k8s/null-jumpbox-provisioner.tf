resource "null_resource" "jumpbox-provisioner" {
  triggers = {
    masters   = join(",", module.vm-masters.vm-ids)
    jumpbox   = join(",", module.vm-jumpbox.vm-id)
    workers   = join(",", module.vm-workers.vm-ids)
    data-disk = azurerm_virtual_machine_data_disk_attachment.master-data-disk.id
  }

  connection {
    host         = module.vm-jumpbox.public-ip
    # bastion_host = azurerm_public_ip.k8s-pip-jump.*.ip_address[0]
    type         = "ssh"
    user         = var.jumpbox.admin-user
    private_key  = file(var.jumpbox.private-key-file)
  }

  provisioner "file" {
    content = templatefile(
        "templates/ssh-config.tmpl",
        {
            hosts = flatten([
                [for i in range(0, var.workers.no-of-workers) : {
                    "name": module.vm-workers.hostnames[i]
                    "ip"  : module.vm-workers.nic-private-ips[i]
                }],
                [for i in range(0, var.masters.no-of-masters) : {
                    "name": module.vm-masters.hostnames[i]
                    "ip"  : module.vm-masters.nic-private-ips[i]
                }],
                {
                    "name": module.vm-jumpbox.hostname[0]
                    "ip"  : module.vm-jumpbox.nic-private-ip[0]
                }
            ])
        }
    )
    destination = format(
        "/home/%s/.ssh/config",
        var.jumpbox.admin-user
    )
  }

  provisioner "file" {
    content     = templatefile(
        "templates/inventory.tmpl",
        {
            admin                        = var.jumpbox.admin-user
            helm_service_account_name    = var.kubernetes.helm-account
            jumpboxes                    = {
                "jumpbox-name": module.vm-jumpbox.vm-name[0]
                "jumpbox-ip"  : module.vm-jumpbox.nic-private-ip[0]
            }
            kubeadm                      = {
                api              = var.kubernetes.api
                api_version      = var.kubernetes.api-version
                api_advertise_ip = module.vm-masters.nic-private-ips[0]
                cert_dir         = var.kubernetes.cert-dir
                cluster_name     = var.kubernetes.cluster-name
                kubeadm_version  = var.kubernetes.kubeadm-version
                pod_subnet       = var.kubernetes.pod-subnet
                service_subnet   = var.kubernetes.service-subnet
                version          = var.kubernetes.version
            }
            master                       = {
                "master-name": module.vm-masters.vm-names[0]
                "master-ip"  : module.vm-workers.nic-private-ips[0]
            }
            master_name                  = module.vm-masters.vm-names[0]
            masters                      = [
                for i in range(0, var.masters.no-of-masters) : {
                    "master-name": module.vm-masters.vm-names[i]
                    "master-ip"  : module.vm-masters.nic-private-ips[i]
                }
            ]
            prod_staging_flag            = "dev"
            registry                     = ""
            workers                      = [
                for i in range(0, var.workers.no-of-workers) : {
                    "worker-name": module.vm-workers.vm-names[i]
                    "worker-ip"  : module.vm-workers.nic-private-ips[i]
                }
            ]
        }
    )
    destination = format(
        "/home/%s/inventory.txt",
        var.jumpbox.admin-user
    )
  }

  provisioner "file" {
    content    = templatefile(
        "templates/bootstrap.sh",
        {
            admin = var.jumpbox.admin-user
        }
    )
    destination = format(
        "/home/%s/bootstrap.sh",
        var.jumpbox.admin-user
    )
  }

  provisioner "remote-exec" {
    inline = [<<EOF
chmod +x ~/bootstrap.sh
sudo ~/bootstrap.sh \
    --auth_file="${data.azurerm_key_vault_secret.nginx-ingress-auth-file.value}" \
    --domain_name="${data.azurerm_key_vault_secret.ddns-domain-name.value}" \
    --email="${data.azurerm_key_vault_secret.email.value}" \
    --nexus_username="${data.azurerm_key_vault_secret.nexus-username.value}" \
    --nexus_password="${data.azurerm_key_vault_secret.nexus-password.value}" \
    --postgres_db="${data.azurerm_key_vault_secret.postgres-db.value}" \
    --postgres_endpoint="${data.azurerm_key_vault_secret.postgres-endpoint.value}" \
    --postgres_password="${data.azurerm_key_vault_secret.admin-password.value}" \
    --postgres_username="${data.azurerm_key_vault_secret.admin-user.value}" \
    --private_key_file="${format("/home/%s/.ssh/id_rsa",var.jumpbox.admin-user)}"
echo "Done.",
EOF
    ]
  }

}