

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ase-230915024406989245"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG2-ase-230915024406989245"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-230915024406989245"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-230915024406989245"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  delegation {
    name = "asedelegation"
    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_app_service_environment_v3" "test" {
  name                = "acctest-ase-230915024406989245"
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.test.id
  zone_redundant      = true
}
