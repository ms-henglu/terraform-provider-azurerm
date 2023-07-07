
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010127163444"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-230707010127163444"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
