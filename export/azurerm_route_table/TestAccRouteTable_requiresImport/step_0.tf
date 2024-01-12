
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034901615507"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt240112034901615507"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
