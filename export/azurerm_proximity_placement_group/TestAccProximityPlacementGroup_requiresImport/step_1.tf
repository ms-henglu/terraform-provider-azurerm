

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023108508789"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-230915023108508789"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_proximity_placement_group" "import" {
  name                = azurerm_proximity_placement_group.test.name
  location            = azurerm_proximity_placement_group.test.location
  resource_group_name = azurerm_proximity_placement_group.test.resource_group_name
}
