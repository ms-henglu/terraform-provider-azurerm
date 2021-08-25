
provider "azurerm" {
  features {}
}

provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-210825045035696409"
  location = "West Europe"
}

data "azuread_service_principal" "test" {
  application_id = "ARM_CLIENT_ID"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver210825045035696409"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"

  azuread_administrator {
    login_username = "AzureAD Admin2"
    object_id      = data.azuread_service_principal.test.id
  }
}
