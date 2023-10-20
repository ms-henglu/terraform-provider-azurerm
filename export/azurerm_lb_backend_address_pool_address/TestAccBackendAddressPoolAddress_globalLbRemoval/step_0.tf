

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041320194573"
  location = "West Europe"
}

resource "azurerm_virtual_network" "backend-vn-R1" {
  name                = "acctestvn-231020041320194573-R1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_virtual_network" "backend-vn-R2" {
  name                = "acctestvn-231020041320194573-R2"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_public_ip" "backend-ip-R1" {
  name                = "acctestpip-231020041320194573-R1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "backend-ip-R1-1" {
  name                = "acctestpip-231020041320194573-R1-1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "backend-ip-R2" {
  name                = "acctestpip-231020041320194573-R2"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "backend-ip-cr" {
  name                = "acctestpip-231020041320194573-cr"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "backend-lb-R1" {
  name                = "acctestlb-231020041320194573-R1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "feip"
    public_ip_address_id = azurerm_public_ip.backend-ip-R1.id
  }
  frontend_ip_configuration {
    name                 = "feip1"
    public_ip_address_id = azurerm_public_ip.backend-ip-R1-1.id
  }
}

resource "azurerm_lb" "backend-lb-R2" {
  name                = "acctestlb-231020041320194573-R2"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "feip"
    public_ip_address_id = azurerm_public_ip.backend-ip-R2.id
  }
}

resource "azurerm_lb" "backend-lb-cr" {
  name                = "acctestlb-231020041320194573-cr"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  sku_tier            = "Global"

  frontend_ip_configuration {
    name                 = "feip"
    public_ip_address_id = azurerm_public_ip.backend-ip-cr.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend-pool-R1" {
  name            = "internal"
  loadbalancer_id = azurerm_lb.backend-lb-R1.id
}

resource "azurerm_lb_backend_address_pool" "backend-pool-R2" {
  name            = "internal"
  loadbalancer_id = azurerm_lb.backend-lb-R2.id
}

resource "azurerm_lb_backend_address_pool" "backend-pool-cr" {
  name            = "myBackendPool-cr"
  loadbalancer_id = azurerm_lb.backend-lb-cr.id
}

resource "azurerm_lb_backend_address_pool_address" "test1" {
  name                                = "address1"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.backend-pool-cr.id
  backend_address_ip_configuration_id = azurerm_lb.backend-lb-R1.frontend_ip_configuration[0].id
}

resource "azurerm_lb_backend_address_pool_address" "test2" {
  name                                = "address2"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.backend-pool-cr.id
  backend_address_ip_configuration_id = azurerm_lb.backend-lb-R2.frontend_ip_configuration[0].id
}
