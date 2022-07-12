
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acragent_pool-220712042108816019"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220712042108816019"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

resource "azurerm_container_registry_agent_pool" "test" {
  name                    = "ap220712042108819"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  container_registry_name = azurerm_container_registry.test.name
}
