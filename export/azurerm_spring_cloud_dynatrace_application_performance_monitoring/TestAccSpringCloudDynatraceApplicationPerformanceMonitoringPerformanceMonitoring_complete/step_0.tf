

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240119025843898360"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240119025843898360"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}


resource "azurerm_spring_cloud_dynatrace_application_performance_monitoring" "test" {
  name                    = "acctest-apm-240119025843898360"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  globally_enabled        = true
  api_url                 = "https://test-api-url.com"
  api_token               = "dt0s01.AAAAAAAAAAAAAAAAAAAAAAAA.BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
  environment_id          = "test-environment-id"
  tenant                  = "test-tenant"
  tenant_token            = "dt0s01.AAAAAAAAAAAAAAAAAAAAAAAA.BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
  connection_point        = "https://example.live.dynatrace.com:443"
}
