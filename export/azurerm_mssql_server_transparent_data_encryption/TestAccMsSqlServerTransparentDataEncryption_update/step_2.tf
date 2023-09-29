

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230929065324045594"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver230929065324045594"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [transparent_data_encryption_key_vault_key_id]
  }
}


resource "azurerm_mssql_server_transparent_data_encryption" "test" {
  server_id = azurerm_mssql_server.test.id
}
