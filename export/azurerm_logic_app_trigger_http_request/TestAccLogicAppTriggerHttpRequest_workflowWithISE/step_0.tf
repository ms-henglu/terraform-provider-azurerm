



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230106034653902325"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-230106034653902325"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/22"]
}

resource "azurerm_subnet" "isesubnet1" {
  name                 = "isesubnet1"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/27"]

  delegation {
    name = "integrationServiceEnvironments"
    service_delegation {
      name    = "Microsoft.Logic/integrationServiceEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "isesubnet2" {
  name                 = "isesubnet2"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.32/27"]
}

resource "azurerm_subnet" "isesubnet3" {
  name                 = "isesubnet3"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.64/27"]
}

resource "azurerm_subnet" "isesubnet4" {
  name                 = "isesubnet4"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.96/27"]
}


resource "azurerm_integration_service_environment" "test" {
  name                 = "acctestRG-logic-230106034653902325"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  sku_name             = "Premium_0"
  access_endpoint_type = "Internal"
  virtual_network_subnet_ids = [
    azurerm_subnet.isesubnet1.id,
    azurerm_subnet.isesubnet2.id,
    azurerm_subnet.isesubnet3.id,
    azurerm_subnet.isesubnet4.id
  ]
}


resource "azurerm_logic_app_workflow" "test" {
  name                               = "acctestlaw-230106034653902325"
  location                           = azurerm_resource_group.test.location
  resource_group_name                = azurerm_resource_group.test.name
  integration_service_environment_id = azurerm_integration_service_environment.test.id
}


resource "azurerm_logic_app_trigger_http_request" "test" {
  name         = "some-http-trigger"
  logic_app_id = azurerm_logic_app_workflow.test.id
  schema       = "{}"
}
