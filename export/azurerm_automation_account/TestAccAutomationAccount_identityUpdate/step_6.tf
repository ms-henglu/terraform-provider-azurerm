
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240112224008101434"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                         = "acctest-240112224008101434"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  sku_name                     = "Basic"
  local_authentication_enabled = false
}
