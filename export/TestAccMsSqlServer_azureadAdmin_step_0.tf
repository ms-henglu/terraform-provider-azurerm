
provider "azurerm" {
  features {}
}

provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-211112020950841081"
  location = "West Europe"
}

data "azuread_service_principal" "test" {
  application_id = "ARM_CLIENT_ID"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver211112020950841081"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = data.azuread_service_principal.test.id
  }
}
