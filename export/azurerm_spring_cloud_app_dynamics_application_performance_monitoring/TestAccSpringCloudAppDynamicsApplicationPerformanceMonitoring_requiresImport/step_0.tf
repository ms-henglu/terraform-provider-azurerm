

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240311033148443111"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240311033148443111"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}


resource "azurerm_spring_cloud_app_dynamics_application_performance_monitoring" "test" {
  name                     = "acctest-apm-240311033148443111"
  spring_cloud_service_id  = azurerm_spring_cloud_service.test.id
  agent_account_name       = "test-agent-account-name"
  agent_account_access_key = "test-agent-account-access-key"
  controller_host_name     = "test-controller-host-name"
}
