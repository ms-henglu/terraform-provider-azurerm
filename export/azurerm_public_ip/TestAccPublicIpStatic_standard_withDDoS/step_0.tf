
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025022024910"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                 = "acctestpublicip-230825025022024910"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  allocation_method    = "Static"
  sku                  = "Standard"
  ddos_protection_mode = "Disabled"
}
