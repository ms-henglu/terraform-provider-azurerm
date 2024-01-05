

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-privatelinkservice-240105064326621965"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet-240105064326621965"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.5.0.0/16"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-240105064326621965"
  sku                 = "Standard"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-240105064326621965"
  sku                 = "Standard"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = azurerm_public_ip.test.name
    public_ip_address_id = azurerm_public_ip.test.id
  }
}


resource "azurerm_subnet" "test" {
  name                 = "acctestsnet-complete-240105064326621965"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.5.1.0/24"]

  enforce_private_link_service_network_policies = true
}

resource "azurerm_private_link_service" "test" {
  name                           = "acctestPLS-240105064326621965"
  location                       = azurerm_resource_group.test.location
  resource_group_name            = azurerm_resource_group.test.name
  auto_approval_subscription_ids = [data.azurerm_subscription.current.subscription_id]
  visibility_subscription_ids    = [data.azurerm_subscription.current.subscription_id]
  fqdns                          = ["foo.com", "bar.com"]

  nat_ip_configuration {
    name                       = "primaryIpConfiguration-240105064326621965"
    subnet_id                  = azurerm_subnet.test.id
    private_ip_address         = "10.5.1.40"
    private_ip_address_version = "IPv4"
    primary                    = true
  }

  nat_ip_configuration {
    name                       = "secondaryIpConfiguration-240105064326621965"
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
