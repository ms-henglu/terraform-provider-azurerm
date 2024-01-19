
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025206719208"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "vault240119025206719208"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy = []

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true

  tags = {
    environment = "Staging"
  }
}
