
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "test" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230113181430457990"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                = "acctestsqlserver230113181430457990"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  version             = "12.0"

  azuread_administrator {
    login_username              = "AzureAD Admin2"
    object_id                   = data.azurerm_client_config.test.object_id
    azuread_authentication_only = true
  }
}
