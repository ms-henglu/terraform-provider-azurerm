
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034431019877"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicipprefix-231016034431019877"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  zones               = ["1", "2", "3"]
}
