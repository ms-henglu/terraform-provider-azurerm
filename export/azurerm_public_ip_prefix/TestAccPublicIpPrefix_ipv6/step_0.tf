
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014003162296"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicipprefix-221111014003162296"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_version          = "IPv6"

  prefix_length = 126
}
