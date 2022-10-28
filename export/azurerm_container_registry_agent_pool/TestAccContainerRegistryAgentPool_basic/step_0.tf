
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acragent_pool-221028171920516949"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr221028171920516949"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

resource "azurerm_container_registry_agent_pool" "test" {
  name                    = "ap221028171920549"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  container_registry_name = azurerm_container_registry.test.name
}
