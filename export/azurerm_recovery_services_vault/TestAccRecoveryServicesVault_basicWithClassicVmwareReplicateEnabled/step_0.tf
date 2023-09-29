
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-230929065548139220"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                               = "acctest-Vault-230929065548139220"
  location                           = azurerm_resource_group.test.location
  resource_group_name                = azurerm_resource_group.test.name
  sku                                = "Standard"
  classic_vmware_replication_enabled = true
  soft_delete_enabled                = false
}
