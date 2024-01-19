
provider "azurerm" {
  features {}
}




resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-240119024724253665"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240119024724253665"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet240119024724253665"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "control" {
  name                 = "control-plane"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/23"]
}



resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv240119024724253665"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id

  infrastructure_subnet_id = azurerm_subnet.control.id

  internal_load_balancer_enabled = true

  tags = {
    Foo    = "Bar"
    secret = "sauce"
  }
}
