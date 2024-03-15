

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240315124113516217"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240315124113516217"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}


resource "azurerm_spring_cloud_new_relic_application_performance_monitoring" "test" {
  name                            = "acctest-apm-240315124113516217"
  spring_cloud_service_id         = azurerm_spring_cloud_service.test.id
  app_name                        = "updated-app-name"
  license_key                     = "updated-license-key"
  agent_enabled                   = false
  app_server_port                 = 8080
  audit_mode_enabled              = true
  auto_app_naming_enabled         = true
  auto_transaction_naming_enabled = false
  custom_tracing_enabled          = false
  labels = {
    tagName1 = "tagValue1"
    tagName2 = "tagValue2"
  }
  globally_enabled = true
}
