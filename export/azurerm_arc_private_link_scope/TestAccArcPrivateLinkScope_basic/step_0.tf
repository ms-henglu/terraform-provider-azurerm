

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728032422812239"
  location = "West Europe"
}


resource "azurerm_arc_private_link_scope" "test" {
  name                = "acctestPLS-230728032422812239"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
