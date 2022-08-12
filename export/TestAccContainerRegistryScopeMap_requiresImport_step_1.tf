

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220812014833986604"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220812014833986604"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

resource "azurerm_container_registry_scope_map" "test" {
  name                    = "testscopemap220812014833986604"
  resource_group_name     = azurerm_resource_group.test.name
  container_registry_name = azurerm_container_registry.test.name
  actions                 = ["repositories/testrepo/content/read"]
}


resource "azurerm_container_registry_scope_map" "import" {
  name                    = azurerm_container_registry_scope_map.test.name
  resource_group_name     = azurerm_container_registry_scope_map.test.resource_group_name
  container_registry_name = azurerm_container_registry_scope_map.test.container_registry_name
  actions                 = azurerm_container_registry_scope_map.test.actions
}
