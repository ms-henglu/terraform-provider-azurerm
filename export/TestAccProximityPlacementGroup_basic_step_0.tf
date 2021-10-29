
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015345462821"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-211029015345462821"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
