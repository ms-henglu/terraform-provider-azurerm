
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025846949396"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver240119025846949396"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"

  identity {
    type = "SystemAssigned"
  }
}
