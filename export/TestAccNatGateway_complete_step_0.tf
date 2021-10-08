
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-211008044745610444"
  location = "West US 2"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicIP-211008044745610444"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicIPPrefix-211008044745610444"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  prefix_length       = 30
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "test" {
  name                    = "acctestnatGateway-211008044745610444"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  public_ip_address_ids   = [azurerm_public_ip.test.id]
  public_ip_prefix_ids    = [azurerm_public_ip_prefix.test.id]
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}
