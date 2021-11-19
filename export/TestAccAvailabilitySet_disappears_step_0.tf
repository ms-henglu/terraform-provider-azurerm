
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119050629359812"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-211119050629359812"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
