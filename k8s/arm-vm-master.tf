module "vm-masters" {
#    source = "git@github.com:dgsd-consulting/tf-library.git//azure/linux-server?ref=v0.3"
    source = "git@github.com:dgsd-consulting/tf-library.git//azure/linux-server"
    linux-server = {
        boot-diagnostics = {
            enable = true
            uri    = azurerm_storage_account.sa.primary_blob_endpoint
        }
        location         = azurerm_resource_group.k8s-rg.location
        network          = {
            private-ip-address = ""
            private-ip-alloc   = "Dynamic"
            public-ip-id       = ""
            subnet-id          = module.k8s-network.subnets.*.id[0]
        }
        os               = {
            admin-user              = var.jumpbox.admin-user
            custom-data             = ""
            disable-password-auth   = true
            hostname                = "master"
            private-key-filename    = var.masters.private-key-file
            public-key              = file(var.masters.public-key-file)
            storage-image-reference = format(
                "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Compute/images/%s",
                var.azure-secrets.subscription-id,
                var.masters.image-rg,
                var.masters.image-name
            )
        }
        os-disk          = {
            caching        = "ReadWrite"
            create-option  = "FromImage"
            disk-size-gb   = 0
            managed-type   = "Premium_LRS"
            delete-on-done = true
        }
        randomizer       = local.l-random
        rg-name          = azurerm_resource_group.k8s-rg.name
        server           = {
            availability-set-id = ""
            machine-size        = var.masters.machine-size
            server-name         = "MASTER"
            server-count        = 1
        }
    }
    tags         = var.tags
}