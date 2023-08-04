
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acragent_pool-230804025658730250"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230804025658730250"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

resource "azurerm_container_registry_agent_pool" "test" {
  name                    = "ap230804025658750"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  container_registry_name = azurerm_container_registry.test.name
}
