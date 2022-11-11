
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014003166602"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-221111014003166602"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"

  ip_version = "IPv6"
}
