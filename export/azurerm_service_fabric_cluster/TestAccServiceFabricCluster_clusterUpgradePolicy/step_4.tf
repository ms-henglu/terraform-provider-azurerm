
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061925973132"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                     = "acctestsa29lq2"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
resource "azurerm_service_fabric_cluster" "test" {
  name                = "acctest-230922061925973132"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  reliability_level   = "Bronze"
  upgrade_mode        = "Automatic"
  vm_image            = "Windows"
  management_endpoint = "http://example:80"
  diagnostics_config {
    storage_account_name       = azurerm_storage_account.test.name
    protected_account_key_name = "StorageAccountKey1"
    blob_endpoint              = azurerm_storage_account.test.primary_blob_endpoint
    queue_endpoint             = azurerm_storage_account.test.primary_queue_endpoint
    table_endpoint             = azurerm_storage_account.test.primary_table_endpoint
  }
  upgrade_policy {
    force_restart_enabled             = true
    health_check_retry_timeout        = "00:00:02"
    health_check_stable_duration      = "00:00:04"
    health_check_wait_duration        = "00:00:06"
    upgrade_domain_timeout            = "00:00:20"
    upgrade_replica_set_check_timeout = "00:00:10"
    upgrade_timeout                   = "00:00:40"
    health_policy {
      max_unhealthy_nodes_percent        = 5
      max_unhealthy_applications_percent = 40
    }
    delta_health_policy {
      max_delta_unhealthy_applications_percent         = 20
      max_delta_unhealthy_nodes_percent                = 40
      max_upgrade_domain_delta_unhealthy_nodes_percent = 60
    }
  }
  node_type {
    name                 = "first"
    instance_count       = 3
    is_primary           = true
    client_endpoint_port = 2020
    http_endpoint_port   = 80
  }
}
