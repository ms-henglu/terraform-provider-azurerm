

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032250785538"
  location = "West Europe"
}


resource "azurerm_arc_private_link_scope" "test" {
  name                = "acctestPLS-240311032250785538"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
