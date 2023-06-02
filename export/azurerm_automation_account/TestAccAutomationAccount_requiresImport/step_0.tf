
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230602030153692273"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-230602030153692273"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}
