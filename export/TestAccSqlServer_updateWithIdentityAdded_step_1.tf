
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003339151081"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver220826003339151081"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"

  identity {
    type = "SystemAssigned"
  }
}
