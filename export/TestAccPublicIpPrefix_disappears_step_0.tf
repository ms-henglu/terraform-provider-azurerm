
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506020301491585"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicipprefix-220506020301491585"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
