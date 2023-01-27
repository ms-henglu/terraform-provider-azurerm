

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230127045156047636"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230127045156047636"
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
  name                    = "testtoken-230127045156047636"
  resource_group_name     = azurerm_resource_group.test.name
  container_registry_name = azurerm_container_registry.test.name
  scope_map_id            = data.azurerm_container_registry_scope_map.pull_repos.id
}


resource "azurerm_container_registry_token_password" "test" {
  container_registry_token_id = azurerm_container_registry_token.test.id
  password1 {
    expiry = "2023-01-27T06:51:56Z"
  }
}

resource "azurerm_resource_group" "consumer" {
  name     = "acctestRG-acr-consumer-230127045156047636"
  location = "West Europe"
  tags = {
    password2 = azurerm_container_registry_token_password.test.password1.0.value
  }
}
