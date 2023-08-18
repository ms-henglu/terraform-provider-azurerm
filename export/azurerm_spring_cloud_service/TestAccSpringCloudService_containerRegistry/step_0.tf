
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230818024828229098"
  location = "West Europe"
}

resource "azurerm_container_registry" "first" {
  name                = "acctestacr2308180248282290981"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  admin_enabled       = true
}

resource "azurerm_container_registry" "second" {
  name                = "acctestacr2308180248282290982"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  admin_enabled       = true
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230818024828229098"
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
    container_registry_name = "first"
  }
}
