
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022336657644"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-220610022336657644"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
