
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204092752808891"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-220204092752808891"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
