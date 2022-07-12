
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042617963438"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet-220712042617963438"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet-220712042617963438"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.1.0.0/24"]

  delegation {
    name = "acctestdelegation-220712042617963438"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_profile" "test" {
  name                = "acctestnetprofile-220712042617963438"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  container_network_interface {
    name = "acctesteth-220712042617963438"

    ip_configuration {
      name      = "acctestipconfig-220712042617963438"
      subnet_id = azurerm_subnet.test.id
    }
  }

  tags = {
    environment = "Staging"
  }
}
