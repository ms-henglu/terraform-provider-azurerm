
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061636833524"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230922061636833524"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
