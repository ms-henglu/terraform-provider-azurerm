

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240311033148468997"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240311033148468997"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}


resource "azurerm_spring_cloud_dynatrace_application_performance_monitoring" "test" {
  name                    = "acctest-apm-240311033148468997"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  globally_enabled        = true
  api_url                 = "https://updated-test-api-url.com"
  api_token               = "dt0s01.BBBBBBBBBBBBBBBBBBBBBBBB.AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  environment_id          = "updated-environment-id"
  tenant                  = "updated-tenant"
  tenant_token            = "dt0s01.BBBBBBBBBBBBBBBBBBBBBBBB.AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  connection_point        = "https://updated.live.dynatrace.com:443"
}
