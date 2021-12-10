
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-211210035236967856"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-vault-211210035236967856"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}

resource "azurerm_site_recovery_fabric" "test" {
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name
  name                = "acctest-fabric-211210035236967856"
  location            = azurerm_resource_group.test.location
}

resource "azurerm_site_recovery_protection_container" "test" {
  resource_group_name  = azurerm_resource_group.test.name
  recovery_vault_name  = azurerm_recovery_services_vault.test.name
  recovery_fabric_name = azurerm_site_recovery_fabric.test.name
  name                 = "acctest-protection-cont-211210035236967856"
}
