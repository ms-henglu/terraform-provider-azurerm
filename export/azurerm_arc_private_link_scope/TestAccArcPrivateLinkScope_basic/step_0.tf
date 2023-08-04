

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030050353757"
  location = "West Europe"
}


resource "azurerm_arc_private_link_scope" "test" {
  name                = "acctestPLS-230804030050353757"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
