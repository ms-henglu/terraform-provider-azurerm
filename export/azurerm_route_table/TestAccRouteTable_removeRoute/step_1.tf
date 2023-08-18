
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818024518182192"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230818024518182192"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
