
	
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-adf-230825024423957591"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestdf230825024423957591"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}


resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet-230825024423957591"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                                           = "acctsub-230825024423957591"
  resource_group_name                            = azurerm_resource_group.test.name
  virtual_network_name                           = azurerm_virtual_network.test.name
  address_prefixes                               = ["10.0.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip230825024423957591"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-230825024423957591"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "internal"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_private_link_service" "test" {
  name                = "acctestPLS-230825024423957591"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  nat_ip_configuration {
    name      = "primaryIpConfiguration-230825024423957591"
    subnet_id = azurerm_subnet.test.id
    primary   = true
  }

  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb.test.frontend_ip_configuration.0.id
  ]
}

resource "azurerm_data_factory_managed_private_endpoint" "test" {
  name               = "acctestEndpoint230825024423957591"
  data_factory_id    = azurerm_data_factory.test.id
  target_resource_id = azurerm_private_link_service.test.id
  fqdns              = ["a.a.a.a.a"]
}
