
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520053718199606"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-220520053718199606"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
