
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025022025089"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230825025022025089"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
