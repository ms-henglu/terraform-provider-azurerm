
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-240105064236166561"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test1" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "test_identity_1"
}

resource "azurerm_user_assigned_identity" "test2" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "test_identity_2"
}

resource "azurerm_mssql_server" "test" {
  name                              = "acctestsqlserver240105064236166561"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = azurerm_resource_group.test.location
  version                           = "12.0"
  administrator_login               = "missadministrator"
  administrator_login_password      = "thisIsKat11"
  primary_user_assigned_identity_id = azurerm_user_assigned_identity.test1.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test1.id, azurerm_user_assigned_identity.test2.id]
  }
}
