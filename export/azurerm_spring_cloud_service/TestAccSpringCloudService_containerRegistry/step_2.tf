
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-231013044316695803"
  location = "West Europe"
}

resource "azurerm_container_registry" "first" {
  name                = "acctestacr2310130443166958031"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  admin_enabled       = true
}

resource "azurerm_container_registry" "second" {
  name                = "acctestacr2310130443166958032"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  admin_enabled       = true
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-231013044316695803"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"

  container_registry {
    name     = "first"
    server   = azurerm_container_registry.first.login_server
    username = azurerm_container_registry.first.admin_username
    password = azurerm_container_registry.first.admin_password
  }

  container_registry {
    name     = "second"
    server   = azurerm_container_registry.second.login_server
    username = azurerm_container_registry.second.admin_username
    password = azurerm_container_registry.second.admin_password
  }

  default_build_service {
    container_registry_name = "second"
  }
}
