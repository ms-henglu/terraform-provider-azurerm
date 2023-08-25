
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024235249082"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-230825024235249082"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
