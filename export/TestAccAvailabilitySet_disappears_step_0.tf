
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021215802473"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-210910021215802473"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
