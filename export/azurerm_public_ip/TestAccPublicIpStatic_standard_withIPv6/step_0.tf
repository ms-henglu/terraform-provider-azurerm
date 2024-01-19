
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527719142"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-240119025527719142"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  ip_version          = "IPv6"
  sku                 = "Standard"
}
