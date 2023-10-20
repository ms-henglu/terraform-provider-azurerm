
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040746101722"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-231020040746101722"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
