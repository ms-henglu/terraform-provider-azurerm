
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072256448188"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt231218072256448188"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
