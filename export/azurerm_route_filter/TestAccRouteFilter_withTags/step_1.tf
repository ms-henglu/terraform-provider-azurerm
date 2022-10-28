
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028165326701470"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf221028165326701470"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
