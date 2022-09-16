
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-220916011916307504"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-Vault-220916011916307504"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}
