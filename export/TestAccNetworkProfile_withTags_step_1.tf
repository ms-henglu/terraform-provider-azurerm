
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014608595182"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet-211015014608595182"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet-211015014608595182"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.1.0.0/24"

  delegation {
    name = "acctestdelegation-211015014608595182"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_profile" "test" {
  name                = "acctestnetprofile-211015014608595182"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  container_network_interface {
    name = "acctesteth-211015014608595182"

    ip_configuration {
      name      = "acctestipconfig-211015014608595182"
      subnet_id = azurerm_subnet.test.id
    }
  }

  tags = {
    environment = "Staging"
  }
}
