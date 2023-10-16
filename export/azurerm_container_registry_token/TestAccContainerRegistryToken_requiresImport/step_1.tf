

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-231016033638167729"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr231016033638167729"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}

# use system wide scope map for tests
data "azurerm_container_registry_scope_map" "pull_repos" {
  name                    = "_repositories_pull"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
}

resource "azurerm_container_registry_token" "test" {
  name                    = "testtoken-231016033638167729"
  resource_group_name     = azurerm_resource_group.test.name
  container_registry_name = azurerm_container_registry.test.name
  scope_map_id            = data.azurerm_container_registry_scope_map.pull_repos.id
}


resource "azurerm_container_registry_token" "import" {
  name                    = azurerm_container_registry_token.test.name
  resource_group_name     = azurerm_container_registry_token.test.resource_group_name
  container_registry_name = azurerm_container_registry_token.test.container_registry_name
  scope_map_id            = azurerm_container_registry_token.test.scope_map_id
}
