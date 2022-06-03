
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603005209912233"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet220603005209912233"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220603005209912233.com"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_private_dns_zone_virtual_network_link" "test" {
  name                  = "acctestVnetZone220603005209912233.com"
  private_dns_zone_name = azurerm_private_dns_zone.test.name
  virtual_network_id    = azurerm_virtual_network.test.id
  resource_group_name   = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
