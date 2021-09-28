
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-210928075809851115"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-210928075809851115"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  version  = "9.6"
  sku_name = "GP_Gen5_2"

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"

  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  ssl_enforcement_enabled = true

  storage_profile {
    storage_mb            = 640000
    backup_retention_days = 7
    geo_redundant_backup  = "Enabled"
    auto_grow             = "Enabled"
  }
}
