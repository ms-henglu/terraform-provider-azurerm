
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-backup-240119025700960052"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "testvlt" {
  name                = "acctest-vault-240119025700960052"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = true
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctzb8kr"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_backup_container_storage_account" "test" {
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.testvlt.name
  storage_account_id  = azurerm_storage_account.test.id
}
