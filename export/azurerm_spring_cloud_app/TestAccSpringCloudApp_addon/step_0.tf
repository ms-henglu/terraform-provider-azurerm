
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230929065733996211"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                     = "acctest-sc-230929065733996211"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  sku_name                 = "E0"
  service_registry_enabled = true
}

resource "azurerm_spring_cloud_configuration_service" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  repository {
    name                     = "fake"
    label                    = "master"
    patterns                 = ["app/dev", "app/prod"]
    uri                      = "https://github.com/Azure-Samples/piggymetrics"
    search_paths             = ["dir1", "dir2"]
    strict_host_key_checking = false
    username                 = "adminuser"
    password                 = "H@Sh1CoR3!"
  }
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-230929065733996211"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
  addon_json = jsonencode({
    applicationConfigurationService = {
      resourceId = azurerm_spring_cloud_configuration_service.test.id
    }
    serviceRegistry = {
      resourceId = azurerm_spring_cloud_service.test.service_registry_id
    }
  })
}
