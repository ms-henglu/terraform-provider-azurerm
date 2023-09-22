
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acragent_pool-230922053854822660"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230922053854822660"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet230922053854822660"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_container_registry_agent_pool" "test" {
  name                      = "ap230922053854860"
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  container_registry_name   = azurerm_container_registry.test.name
  instance_count            = 2
  tier                      = "S2"
  virtual_network_subnet_id = azurerm_subnet.test.id
}

