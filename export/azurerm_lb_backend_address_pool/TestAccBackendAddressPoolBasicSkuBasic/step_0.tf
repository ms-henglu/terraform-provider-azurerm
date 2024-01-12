
provider "azurerm" {
  features {}
}


locals {
  number   = 240112034623251107
  location = "West Europe"
  sku      = "Basic"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-${local.number}"
  location = local.location
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-${local.number}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-${local.number}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = local.sku
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-${local.number}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = local.sku

  frontend_ip_configuration {
    name                 = "feip"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}


resource "azurerm_lb_backend_address_pool" "test" {
  name            = "pool"
  loadbalancer_id = azurerm_lb.test.id
}
