

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acragent_pool-231020040818465863"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr231020040818465863"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

resource "azurerm_container_registry_agent_pool" "test" {
  name                    = "ap231020040818463"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  container_registry_name = azurerm_container_registry.test.name
}


resource "azurerm_container_registry_agent_pool" "import" {
  name                    = azurerm_container_registry_agent_pool.test.name
  resource_group_name     = azurerm_container_registry_agent_pool.test.resource_group_name
  location                = azurerm_container_registry_agent_pool.test.location
  container_registry_name = azurerm_container_registry_agent_pool.test.container_registry_name
}

