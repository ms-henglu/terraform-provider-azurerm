

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021055701746"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet-211001021055701746"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet-211001021055701746"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.1.0.0/24"

  delegation {
    name = "acctestdelegation-211001021055701746"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_profile" "test" {
  name                = "acctestnetprofile-211001021055701746"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  container_network_interface {
    name = "acctesteth-211001021055701746"

    ip_configuration {
      name      = "acctestipconfig-211001021055701746"
      subnet_id = azurerm_subnet.test.id
    }
  }
}


resource "azurerm_network_profile" "import" {
  name                = azurerm_network_profile.test.name
  location            = azurerm_network_profile.test.location
  resource_group_name = azurerm_network_profile.test.resource_group_name

  container_network_interface {
    name = azurerm_network_profile.test.container_network_interface[0].name

    ip_configuration {
      name      = azurerm_network_profile.test.container_network_interface[0].ip_configuration[0].name
      subnet_id = azurerm_subnet.test.id
    }
  }
}
