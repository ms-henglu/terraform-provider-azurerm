
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230113181430455119"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver230113181430455119"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"
  minimum_tls_version          = "1.1"

  identity {
    type = "SystemAssigned"
  }
}
