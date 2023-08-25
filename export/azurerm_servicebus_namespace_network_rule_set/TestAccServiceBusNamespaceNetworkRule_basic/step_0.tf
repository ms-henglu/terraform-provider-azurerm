

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sb-230825025259400261"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-sb-namespace-230825025259400261"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Premium"

  capacity = 1
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-230825025259400261"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["172.17.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

resource "azurerm_subnet" "test" {
  name                 = "${azurerm_virtual_network.test.name}-default"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["172.17.0.0/24"]

  service_endpoints = ["Microsoft.ServiceBus"]
}


resource "azurerm_servicebus_namespace_network_rule_set" "test" {
  namespace_id = azurerm_servicebus_namespace.test.id

  default_action = "Deny"

  network_rules {
    subnet_id                            = azurerm_subnet.test.id
    ignore_missing_vnet_service_endpoint = false
  }
}
