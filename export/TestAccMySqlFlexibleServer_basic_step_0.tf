

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-220712042600256019"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-220712042600256019"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "_admin_Terraform_892123456789312"
  administrator_password = "QAZwsx123"
  sku_name               = "B_Standard_B1s"
  zone                   = "1"
}
