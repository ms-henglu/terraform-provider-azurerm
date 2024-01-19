
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-240119025700989650"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-Vault-240119025700989650"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}
