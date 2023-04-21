
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421021839845678"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-230421021839845678"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
