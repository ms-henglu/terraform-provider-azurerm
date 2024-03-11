

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240311033148441155"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240311033148441155"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-240311033148441155"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}

resource "azurerm_mysql_server" "test" {
  name                             = "acctestmysqlsvr-240311033148441155"
  location                         = azurerm_resource_group.test.location
  resource_group_name              = azurerm_resource_group.test.name
  sku_name                         = "GP_Gen5_2"
  administrator_login              = "acctestun"
  administrator_login_password     = "H@Sh1CoR3!"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_1"
  storage_mb                       = 51200
  version                          = "5.7"
}

resource "azurerm_mysql_database" "test" {
  name                = "acctest-db-240311033148441155"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mysql_server.test.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}


resource "azurerm_spring_cloud_app_mysql_association" "test" {
  name                = "acctestscamb-240311033148441155"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
  mysql_server_id     = azurerm_mysql_server.test.id
  database_name       = azurerm_mysql_database.test.name
  username            = azurerm_mysql_server.test.administrator_login
  password            = azurerm_mysql_server.test.administrator_login_password
}
