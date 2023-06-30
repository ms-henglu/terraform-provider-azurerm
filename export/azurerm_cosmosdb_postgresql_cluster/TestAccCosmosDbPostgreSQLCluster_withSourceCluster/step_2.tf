


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pshsc-230630032935090217"
  location = "West Europe"
}


resource "azurerm_cosmosdb_postgresql_cluster" "test" {
  name                            = "acctestcluster230630032935090217"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  administrator_login_password    = "H@Sh1CoR3!"
  coordinator_storage_quota_in_mb = 131072
  coordinator_vcore_count         = 2
  node_count                      = 0
}


resource "azurerm_cosmosdb_postgresql_cluster" "test2" {
  name                 = "acctesttcluster230630032935090217"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  source_location      = azurerm_cosmosdb_postgresql_cluster.test.location
  source_resource_id   = azurerm_cosmosdb_postgresql_cluster.test.id
  point_in_time_in_utc = azurerm_cosmosdb_postgresql_cluster.test.earliest_restore_time

  administrator_login_password    = "H@Sh1CoR3!"
  coordinator_storage_quota_in_mb = 131072
  coordinator_vcore_count         = 2
  node_count                      = 0
}
