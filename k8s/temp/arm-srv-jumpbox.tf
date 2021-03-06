module "k8s-jumpbox" {
  source          = "git@github.com:dgsd-consulting/tf-library.git//azure/linux-jumpbox?ref=v0.1"

  jumpbox         = {
    admin-user              = var.jumpbox.admin-user
    availability-set-id     = ""
    boot-diags              = true
    boot-diags-sa-uri       = module.k8s-storage-account.primary_blob_endpoint
    custom-data             = ""
    domain-name-label       = "djs-k8s-bare"
    jumpbox-name            = format(
      "%s-jumpbox",
      var.resources.name-prefix
    )
    location                = azurerm_resource_group.k8s-rg.location
    machine-size            = var.jumpbox.machine-size
    nsg-id                  = azurerm_network_security_group.jumpbox-nsg.id
    nsg-name                = azurerm_network_security_group.jumpbox-nsg.name
    nsg-rule-number         = "100"
    public-key              = file(var.jumpbox.public-key-file)
    randomizer              = local.l-random
    name                 = azurerm_resource_group.k8s-rg.name
    subnet-id               = module.k8s-network.subnet-ids[2]
    storage-image-reference = format(
      "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Compute/images/%s",
      var.azure-secrets.subscription-id,
      var.jumpbox.image-rg,
      var.jumpbox.image-name
    )
  }
  tags            = var.tags
}
