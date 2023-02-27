
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227032410567423"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-230227032410567423"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
