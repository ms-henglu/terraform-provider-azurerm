
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-231218072427686372"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                          = "acctest-Vault-231218072427686372"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  sku                           = "Standard"
  public_network_access_enabled = true

  soft_delete_enabled = false
}
