
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415030723236695"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220415030723236695"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
