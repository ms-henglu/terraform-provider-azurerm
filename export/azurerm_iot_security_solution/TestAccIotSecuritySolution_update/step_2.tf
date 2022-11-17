

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-security-221117231428767725"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-221117231428767725"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}


data "azurerm_client_config" "test" {}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-221117231428767725"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_iot_security_solution" "test" {
  name                       = "acctest-Iot-Security-Solution-221117231428767725"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  display_name               = "Iot Security Solution"
  iothub_ids                 = [azurerm_iothub.test.id]
  enabled                    = true
  log_unmasked_ips_enabled   = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  events_to_export           = ["RawEvents"]
  disabled_data_sources      = ["TwinData"]

  recommendations_enabled {
    acr_authentication               = false
    agent_send_unutilized_msg        = false
    baseline                         = false
    edge_hub_mem_optimize            = false
    edge_logging_option              = false
    inconsistent_module_settings     = false
    install_agent                    = false
    ip_filter_deny_all               = false
    ip_filter_permissive_rule        = false
    open_ports                       = false
    permissive_firewall_policy       = false
    permissive_input_firewall_rules  = false
    permissive_output_firewall_rules = false
    privileged_docker_options        = false
    shared_credentials               = false
    vulnerable_tls_cipher_suite      = false
  }

  query_for_resources    = "where type != \"microsoft.devices/iothubs\" | where name contains \"iot\""
  query_subscription_ids = [data.azurerm_client_config.test.subscription_id]

  tags = {
    "Env" : "Staging"
  }
}
