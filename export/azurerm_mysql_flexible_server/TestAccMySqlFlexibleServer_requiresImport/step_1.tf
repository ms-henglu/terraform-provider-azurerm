


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-240119025452499803"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-240119025452499803"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "_admin_Terraform_892123456789312"
  administrator_password = "QAZwsx123"
  sku_name               = "B_Standard_B1s"
  zone                   = "1"
}


resource "azurerm_mysql_flexible_server" "import" {
  name                   = azurerm_mysql_flexible_server.test.name
  resource_group_name    = azurerm_mysql_flexible_server.test.resource_group_name
  location               = azurerm_mysql_flexible_server.test.location
  administrator_login    = azurerm_mysql_flexible_server.test.administrator_login
  administrator_password = azurerm_mysql_flexible_server.test.administrator_password
  sku_name               = azurerm_mysql_flexible_server.test.sku_name
  zone                   = azurerm_mysql_flexible_server.test.zone
}
