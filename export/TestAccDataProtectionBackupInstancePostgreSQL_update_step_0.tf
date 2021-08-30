

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-210830083912842207"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-postgresql-server-210830083912842207"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladminun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "test" {
  name                = "acctest-postgresql-database-210830083912842207"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_postgresql_server.test.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dataprotection-vault-210830083912842207"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_protection_backup_policy_postgresql" "test" {
  name                            = "acctest-dp-210830083912842207"
  resource_group_name             = azurerm_resource_group.test.name
  vault_name                      = azurerm_data_protection_backup_vault.test.name
  backup_repeating_time_intervals = ["R/2021-05-23T02:30:00+00:00/P1W"]
  default_retention_duration      = "P4M"
}

resource "azurerm_data_protection_backup_policy_postgresql" "another" {
  name                            = "acctest-dp-second-210830083912842207"
  resource_group_name             = azurerm_resource_group.test.name
  vault_name                      = azurerm_data_protection_backup_vault.test.name
  backup_repeating_time_intervals = ["R/2021-05-23T02:30:00+00:00/P1W"]
  default_retention_duration      = "P3M"
}


resource "azurerm_data_protection_backup_instance_postgresql" "test" {
  name             = "acctest-dbi-210830083912842207"
  location         = azurerm_resource_group.test.location
  vault_id         = azurerm_data_protection_backup_vault.test.id
  database_id      = azurerm_postgresql_database.test.id
  backup_policy_id = azurerm_data_protection_backup_policy_postgresql.test.id
}
