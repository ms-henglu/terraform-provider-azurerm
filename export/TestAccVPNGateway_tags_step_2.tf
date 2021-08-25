

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825045101569140"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-210825045101569140"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan-210825045101569140"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctestvh-210825045101569140"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_prefix      = "10.0.1.0/24"
  virtual_wan_id      = azurerm_virtual_wan.test.id
}


resource "azurerm_vpn_gateway" "test" {
  name                = "acctestVPNG-210825045101569140"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_hub_id      = azurerm_virtual_hub.test.id

  tags = {
    Hello = "World"
    Rick  = "C-137"
  }
}
