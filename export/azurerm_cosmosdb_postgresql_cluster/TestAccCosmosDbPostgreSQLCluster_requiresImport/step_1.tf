


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pshsc-240112224223195393"
  location = "West Europe"
}


resource "azurerm_cosmosdb_postgresql_cluster" "test" {
  name                            = "acctestcluster240112224223195393"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  administrator_login_password    = "H@Sh1CoR3!"
  coordinator_storage_quota_in_mb = 131072
  coordinator_vcore_count         = 2
  node_count                      = 0
}


resource "azurerm_cosmosdb_postgresql_cluster" "import" {
  name                            = azurerm_cosmosdb_postgresql_cluster.test.name
  resource_group_name             = azurerm_cosmosdb_postgresql_cluster.test.resource_group_name
  location                        = azurerm_cosmosdb_postgresql_cluster.test.location
  administrator_login_password    = azurerm_cosmosdb_postgresql_cluster.test.administrator_login_password
  coordinator_storage_quota_in_mb = azurerm_cosmosdb_postgresql_cluster.test.coordinator_storage_quota_in_mb
  coordinator_vcore_count         = azurerm_cosmosdb_postgresql_cluster.test.coordinator_vcore_count
  node_count                      = azurerm_cosmosdb_postgresql_cluster.test.node_count
}
