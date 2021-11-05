

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-privatelinkservice-211105040250081346"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet-211105040250081346"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.5.0.0/16"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-211105040250081346"
  sku                 = "Standard"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-211105040250081346"
  sku                 = "Standard"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = azurerm_public_ip.test.name
    public_ip_address_id = azurerm_public_ip.test.id
  }
}


resource "azurerm_subnet" "test" {
  name                 = "acctestsnet-complete-211105040250081346"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.5.1.0/24"

  enforce_private_link_service_network_policies = true
}

resource "azurerm_private_link_service" "test" {
  name                           = "acctestPLS-211105040250081346"
  location                       = azurerm_resource_group.test.location
  resource_group_name            = azurerm_resource_group.test.name
  auto_approval_subscription_ids = [data.azurerm_subscription.current.subscription_id]
  visibility_subscription_ids    = [data.azurerm_subscription.current.subscription_id]

  nat_ip_configuration {
    name                       = "primaryIpConfiguration-211105040250081346"
    subnet_id                  = azurerm_subnet.test.id
    private_ip_address         = "10.5.1.40"
    private_ip_address_version = "IPv4"
    primary                    = true
  }

  nat_ip_configuration {
    name                       = "secondaryIpConfiguration-211105040250081346"
    subnet_id                  = azurerm_subnet.test.id
    private_ip_address         = "10.5.1.41"
    private_ip_address_version = "IPv4"
    primary                    = false
  }

  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb.test.frontend_ip_configuration.0.id
  ]

  tags = {
    env = "test"
  }
}
