

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041218354923"
  location = "West Europe"
}


resource "azurerm_arc_private_link_scope" "test" {
  name                = "acctestPLS-231020041218354923"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
