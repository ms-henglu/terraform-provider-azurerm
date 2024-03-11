


provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240311033148461203"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240311033148461203"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}


resource "azurerm_spring_cloud_dynatrace_application_performance_monitoring" "test" {
  name                    = "acctest-dapm-240311033148461203"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  tenant                  = "test-tenant"
  tenant_token            = "dt0s01.AAAAAAAAAAAAAAAAAAAAAAAA.BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
  connection_point        = "https://example.live.dynatrace.com:443"
}

resource "azurerm_spring_cloud_elastic_application_performance_monitoring" "test" {
  name                    = "acctest-eapm-240311033148461203"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  application_packages    = ["org.example", "org.another.example"]
  service_name            = "test-service-name"
  server_url              = "http://127.0.0.1:8200"
}


resource "azurerm_spring_cloud_gateway" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}
