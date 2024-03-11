

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-240311031710529827"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr240311031710529827"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  admin_enabled       = true
}

# use system wide scope map for tests
data "azurerm_container_registry_scope_map" "pull_repos" {
  name                    = "_repositories_pull"
  container_registry_name = azurerm_container_registry.test.name
  resource_group_name     = azurerm_container_registry.test.resource_group_name
}

resource "azurerm_container_registry_token" "test" {
  name                    = "testtoken-240311031710529827"
  resource_group_name     = azurerm_resource_group.test.name
  container_registry_name = azurerm_container_registry.test.name
  scope_map_id            = data.azurerm_container_registry_scope_map.pull_repos.id
}


resource "azurerm_container_registry_token_password" "test" {
  container_registry_token_id = azurerm_container_registry_token.test.id
  password1 {
    expiry = "2024-03-11T04:17:10Z"
  }
}

resource "azurerm_resource_group" "consumer" {
  name     = "acctestRG-acr-consumer-240311031710529827"
  location = "West Europe"
  tags = {
    password1 = azurerm_container_registry_token_password.test.password1.0.value
  }
}
