
	
provider "azurerm" {
  features {
  }
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-alb-231218072555965934"
  location = "West Europe"
}

resource "azurerm_application_load_balancer" "test" {
  name                = "acctestalb-231218072555965934"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet231218072555965934"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet231218072555965934"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ServiceNetworking/trafficControllers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}



resource "azurerm_application_load_balancer_subnet_association" "test" {
  name                         = "acct-231218072555965934"
  application_load_balancer_id = azurerm_application_load_balancer.test.id
  subnet_id                    = azurerm_subnet.test.id
}


resource "azurerm_application_load_balancer_subnet_association" "import" {
  name                         = azurerm_application_load_balancer_subnet_association.test.name
  application_load_balancer_id = azurerm_application_load_balancer_subnet_association.test.application_load_balancer_id
  subnet_id                    = azurerm_application_load_balancer_subnet_association.test.subnet_id
}
