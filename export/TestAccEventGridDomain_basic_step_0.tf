
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506005727800139"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-220506005727800139"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
