

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-230825025153625220"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-Vault-230825025153625220"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}


resource "azurerm_recovery_services_vault" "import" {
  name                = azurerm_recovery_services_vault.test.name
  location            = azurerm_recovery_services_vault.test.location
  resource_group_name = azurerm_recovery_services_vault.test.resource_group_name
  sku                 = azurerm_recovery_services_vault.test.sku
}
