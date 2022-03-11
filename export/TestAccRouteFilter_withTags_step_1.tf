
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311042816874092"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220311042816874092"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
