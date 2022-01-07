
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107063800570359"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-220107063800570359"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
