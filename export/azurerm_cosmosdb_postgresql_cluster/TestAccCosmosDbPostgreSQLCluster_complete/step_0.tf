

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pshsc-231013043220274287"
  location = "West Europe"
}


resource "azurerm_cosmosdb_postgresql_cluster" "test" {
  name                = "acctestcluster231013043220274287"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  administrator_login_password    = "H@Sh1CoR3!"
  coordinator_storage_quota_in_mb = 131072
  coordinator_vcore_count         = 2
  node_count                      = 0

  citus_version                        = "11.1"
  coordinator_public_ip_access_enabled = true
  ha_enabled                           = false
  coordinator_server_edition           = "GeneralPurpose"

  maintenance_window {
    day_of_week  = 0
    start_hour   = 8
    start_minute = 0
  }

  node_public_ip_access_enabled = false
  node_server_edition           = "MemoryOptimized"
  sql_version                   = "14"
  preferred_primary_zone        = 1
  node_storage_quota_in_mb      = 131072
  node_vcores                   = 2
  shards_on_coordinator_enabled = true

  tags = {
    Env = "Test"
  }
}
