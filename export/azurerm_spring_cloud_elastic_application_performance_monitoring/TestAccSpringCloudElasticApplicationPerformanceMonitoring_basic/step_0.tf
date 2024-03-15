

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240315124113501466"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240315124113501466"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}


resource "azurerm_spring_cloud_elastic_application_performance_monitoring" "test" {
  name                    = "acctest-apm-240315124113501466"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  application_packages    = ["org.example", "org.another.example"]
  service_name            = "test-service-name"
  server_url              = "http://127.0.0.1:8200"
}
