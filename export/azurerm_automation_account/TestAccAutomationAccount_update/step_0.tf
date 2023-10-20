
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-231020040612483125"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                         = "acctest-231020040612483125"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  sku_name                     = "Basic"
  local_authentication_enabled = false
}
