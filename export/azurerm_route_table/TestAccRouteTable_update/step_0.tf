
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034431026205"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt231016034431026205"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
