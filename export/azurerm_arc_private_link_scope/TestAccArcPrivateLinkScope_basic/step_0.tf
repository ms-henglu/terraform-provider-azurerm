

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034042187278"
  location = "West Europe"
}


resource "azurerm_arc_private_link_scope" "test" {
  name                = "acctestPLS-231016034042187278"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
