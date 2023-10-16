


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-231016034356098025"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-231016034356098025"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "_admin_Terraform_892123456789312"
  administrator_password = "QAZwsx123"
  sku_name               = "B_Standard_B1s"
  zone                   = "1"
}


resource "azurerm_mysql_flexible_server" "pitr" {
  name                              = "acctest-fs-pitr-231016034356098025"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = azurerm_resource_group.test.location
  create_mode                       = "PointInTimeRestore"
  source_server_id                  = azurerm_mysql_flexible_server.test.id
  point_in_time_restore_time_in_utc = "2023-10-16T03:58:56Z"
  zone                              = "1"
}
