

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240315124113494587"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240315124113494587"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}


resource "azurerm_spring_cloud_app_dynamics_application_performance_monitoring" "test" {
  name                     = "acctest-apm-240315124113494587"
  spring_cloud_service_id  = azurerm_spring_cloud_service.test.id
  agent_account_name       = "updated-agent-account-name"
  agent_account_access_key = "updated-agent-account-access-key"
  controller_host_name     = "updated-controller-host-name"
  agent_application_name   = "test-agent-application-name"
  agent_tier_name          = "test-agent-tier-name"
  agent_node_name          = "test-agent-node-name"
  agent_unique_host_id     = "test-agent-unique-host-id"
  controller_ssl_enabled   = true
  controller_port          = 8080
  globally_enabled         = true
}
