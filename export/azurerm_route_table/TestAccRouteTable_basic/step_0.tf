
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224958269220"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt240112224958269220"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
