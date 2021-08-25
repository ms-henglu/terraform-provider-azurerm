
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825031517135957"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-210825031517135957"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
