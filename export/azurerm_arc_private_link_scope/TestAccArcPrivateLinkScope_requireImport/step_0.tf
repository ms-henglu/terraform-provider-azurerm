

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022205025932"
  location = "West Europe"
}


resource "azurerm_arc_private_link_scope" "test" {
  name                = "acctestPLS-240119022205025932"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
