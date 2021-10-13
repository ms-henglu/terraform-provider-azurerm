
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072215416359"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicipprefix-211013072215416359"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  prefix_length = 24
}
