
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "test" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230804030340623291"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver230804030340623291"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = data.azurerm_client_config.test.object_id
  }
}
