
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acragent_pool-231016033638135565"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr231016033638135565"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

resource "azurerm_container_registry_agent_pool" "test" {
  name                    = "ap231016033638165"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  container_registry_name = azurerm_container_registry.test.name
}
