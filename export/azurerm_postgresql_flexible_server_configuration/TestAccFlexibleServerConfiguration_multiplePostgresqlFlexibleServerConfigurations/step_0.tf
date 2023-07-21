


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-230721015811301675"
  location = "West Europe"
}


resource "azurerm_virtual_network" "test" {
  name                = "acctest-vn-230721015811301675"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-sn-230721015811301675"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acc230721015811301675.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "test" {
  name                  = "acctestVnetZone230721015811301675.com"
  private_dns_zone_name = azurerm_private_dns_zone.test.name
  virtual_network_id    = azurerm_virtual_network.test.id
  resource_group_name   = azurerm_resource_group.test.name
}

resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-230721015811301675"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  version                = "13"
  backup_retention_days  = 7
  storage_mb             = 32768
  delegated_subnet_id    = azurerm_subnet.test.id
  private_dns_zone_id    = azurerm_private_dns_zone.test.id
  sku_name               = "GP_Standard_D2s_v3"
  zone                   = "1"

  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }

  maintenance_window {
    day_of_week  = 0
    start_hour   = 8
    start_minute = 0
  }

  tags = {
    ENV = "Test"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.test]
}


resource "azurerm_postgresql_flexible_server_configuration" "test" {
  name      = "idle_in_transaction_session_timeout"
  server_id = azurerm_postgresql_flexible_server.test.id
  value     = "60"
}

resource "azurerm_postgresql_flexible_server_configuration" "test2" {
  name      = "log_autovacuum_min_duration"
  server_id = azurerm_postgresql_flexible_server.test.id
  value     = "10"
}

resource "azurerm_postgresql_flexible_server_configuration" "test3" {
  name      = "log_lock_waits"
  server_id = azurerm_postgresql_flexible_server.test.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "test4" {
  name      = "log_min_duration_statement"
  server_id = azurerm_postgresql_flexible_server.test.id
  value     = "10"
}

resource "azurerm_postgresql_flexible_server_configuration" "test5" {
  name      = "log_statement"
  server_id = azurerm_postgresql_flexible_server.test.id
  value     = "ddl"
}
