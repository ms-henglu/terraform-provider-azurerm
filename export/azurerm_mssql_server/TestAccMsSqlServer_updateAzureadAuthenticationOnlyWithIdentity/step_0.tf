
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "test" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230915023830604940"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "test_identity_1"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver230915023830604940"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  minimum_tls_version          = "1.2"
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"

  azuread_administrator {
    login_username              = "AzureAD Admin"
    object_id                   = data.azurerm_client_config.test.object_id
    azuread_authentication_only = false
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  primary_user_assigned_identity_id = azurerm_user_assigned_identity.test.id
}
