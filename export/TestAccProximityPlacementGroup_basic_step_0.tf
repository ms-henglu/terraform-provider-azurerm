
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075302192813"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-210928075302192813"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
