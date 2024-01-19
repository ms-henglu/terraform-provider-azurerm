
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-240119024724259359"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240119024724259359"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet240119024724259359"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "control" {
  name                 = "control-plane"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/23"]
  delegation {
    name = "acctestdelegation240119024724259359"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.App/environments"
    }
  }
}

resource "azurerm_container_app_environment" "test" {
  name                     = "acctest-CAEnv240119024724259359"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  infrastructure_subnet_id = azurerm_subnet.control.id

  workload_profile {
    maximum_count         = 2
    minimum_count         = 0
    name                  = "My-GP-01"
    workload_profile_type = "D4"
  }

  zone_redundancy_enabled = true

  tags = {
    Foo    = "Bar"
    secret = "sauce"
  }
}
