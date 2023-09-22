
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-230922061808528441"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-vault-230922061808528441"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}

resource "azurerm_data_protection_resource_guard" "test" {
  name                = "acctest-dprg-230922061808528441"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_recovery_services_vault_resource_guard_association" "test" {
  name              = "VaultProxy"
  vault_id          = azurerm_recovery_services_vault.test.id
  resource_guard_id = azurerm_data_protection_resource_guard.test.id
}
