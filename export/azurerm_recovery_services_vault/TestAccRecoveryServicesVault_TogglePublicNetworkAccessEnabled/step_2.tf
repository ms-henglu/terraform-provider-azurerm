
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-230519075501490703"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                          = "acctest-Vault-230519075501490703"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  sku                           = "Standard"
  public_network_access_enabled = true

  soft_delete_enabled = false
}
