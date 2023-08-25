

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pshsc-230825024317965970"
  location = "West Europe"
}


resource "azurerm_cosmosdb_postgresql_cluster" "test" {
  name                            = "acctestcluster230825024317965970"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  administrator_login_password    = "H@Sh1CoR3!"
  coordinator_storage_quota_in_mb = 131072
  coordinator_vcore_count         = 2
  node_count                      = 0
}
