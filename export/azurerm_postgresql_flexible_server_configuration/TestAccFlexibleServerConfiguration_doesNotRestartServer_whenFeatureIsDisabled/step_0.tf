
provider "azurerm" {
  features {
    postgresql_flexible_server {
      restart_server_on_configuration_value_change = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-240315123819770295"
  location = "West Europe"
}

resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-240315123819770295"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  storage_mb             = 32768
  version                = "12"
  sku_name               = "GP_Standard_D2s_v3"
  zone                   = "2"
}

resource "azurerm_postgresql_flexible_server_configuration" "test" {
  name      = "cron.max_running_jobs"
  server_id = azurerm_postgresql_flexible_server.test.id
  value     = "5"
}
