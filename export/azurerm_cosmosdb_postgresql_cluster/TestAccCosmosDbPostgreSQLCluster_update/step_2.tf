

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pshsc-230825024317967268"
  location = "West Europe"
}


resource "azurerm_cosmosdb_postgresql_cluster" "test" {
  name                = "acctestcluster230825024317967268"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  administrator_login_password    = "H@Sh1CoR4!"
  coordinator_storage_quota_in_mb = 262144
  coordinator_vcore_count         = 4
  node_count                      = 2

  citus_version                        = "11.3"
  coordinator_public_ip_access_enabled = false
  ha_enabled                           = true
  coordinator_server_edition           = "MemoryOptimized"

  maintenance_window {
    day_of_week  = 1
    start_hour   = 9
    start_minute = 1
  }

  node_public_ip_access_enabled = true
  node_server_edition           = "GeneralPurpose"
  sql_version                   = "15"
  preferred_primary_zone        = 2
  node_storage_quota_in_mb      = 262144
  node_vcores                   = 4
  shards_on_coordinator_enabled = false

  tags = {
    Env = "Test2"
  }
}
