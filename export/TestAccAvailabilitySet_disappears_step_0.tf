
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001020609128663"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-211001020609128663"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
