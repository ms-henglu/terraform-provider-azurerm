
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072215428085"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-211013072215428085"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  allocation_method = "Static"
  domain_name_label = "qz8znezhh1zo9d78lqfmgabg9rq0711jn7so2uxe3tc8wx79ziyc9n31pmnz4zm"
}
