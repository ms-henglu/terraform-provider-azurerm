

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825045101508056"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet-210825045101508056"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet-210825045101508056"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.1.0.0/24"

  delegation {
    name = "acctestdelegation-210825045101508056"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_profile" "test" {
  name                = "acctestnetprofile-210825045101508056"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  container_network_interface {
    name = "acctesteth-210825045101508056"

    ip_configuration {
      name      = "acctestipconfig-210825045101508056"
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
