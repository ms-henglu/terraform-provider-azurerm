

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240311033148468628"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240311033148468628"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}


resource "azurerm_spring_cloud_new_relic_application_performance_monitoring" "test" {
  name                    = "acctest-apm-240311033148468628"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  app_name                = "test-app-name"
  license_key             = "test-license-key"
}
