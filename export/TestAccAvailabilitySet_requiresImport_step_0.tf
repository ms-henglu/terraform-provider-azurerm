
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220818234946060275"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-220818234946060275"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
