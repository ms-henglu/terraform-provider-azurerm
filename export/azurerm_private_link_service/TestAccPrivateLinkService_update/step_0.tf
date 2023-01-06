

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-privatelinkservice-230106034829574578"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet-230106034829574578"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.5.0.0/16"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-230106034829574578"
  sku                 = "Standard"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-230106034829574578"
  sku                 = "Standard"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = azurerm_public_ip.test.name
    public_ip_address_id = azurerm_public_ip.test.id
  }
}


resource "azurerm_subnet" "test" {
  name                 = "acctestsnet-update-230106034829574578"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.5.3.0/24"]

  enforce_private_link_service_network_policies = true
}

resource "azurerm_private_link_service" "test" {
  name                = "acctestPLS-230106034829574578"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  nat_ip_configuration {
    name                       = "primaryIpConfiguration-230106034829574578"
    subnet_id                  = azurerm_subnet.test.id
    private_ip_address         = "10.5.3.30"
    private_ip_address_version = "IPv4"
    primary                    = true
  }

  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb.test.frontend_ip_configuration.0.id
  ]
}
