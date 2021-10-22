
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211022002133194567"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-211022002133194567"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
