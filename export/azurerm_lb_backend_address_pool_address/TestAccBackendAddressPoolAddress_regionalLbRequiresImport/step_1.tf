


provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061020401142"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-240105061020401142"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-240105061020401142"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-240105061020401142"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "feip"
    public_ip_address_id = azurerm_public_ip.test.id
  }
  depends_on = [azurerm_public_ip.test]
}

resource "azurerm_lb_backend_address_pool" "test" {
  name            = "internal"
  loadbalancer_id = azurerm_lb.test.id
  depends_on      = [azurerm_lb.test]
}


resource "azurerm_lb_backend_address_pool_address" "test" {
  name                    = "address"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
  virtual_network_id      = azurerm_virtual_network.test.id
  ip_address              = "191.168.0.1"
  depends_on              = [azurerm_lb_backend_address_pool.test]
}


resource "azurerm_lb_backend_address_pool_address" "import" {
  name                    = azurerm_lb_backend_address_pool_address.test.name
  backend_address_pool_id = azurerm_lb_backend_address_pool_address.test.backend_address_pool_id
  virtual_network_id      = azurerm_lb_backend_address_pool_address.test.virtual_network_id
  ip_address              = azurerm_lb_backend_address_pool_address.test.ip_address
}
