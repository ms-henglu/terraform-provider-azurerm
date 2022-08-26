
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003111899290"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet-220826003111899290"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet-220826003111899290"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.1.0.0/24"]

  delegation {
    name = "acctestdelegation-220826003111899290"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_profile" "test" {
  name                = "acctestnetprofile-220826003111899290"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  container_network_interface {
    name = "acctesteth-220826003111899290"

    ip_configuration {
      name      = "acctestipconfig-220826003111899290"
      subnet_id = azurerm_subnet.test.id
    }
  }
}
