


provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysqlfsaad-231016034356085146"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-231016034356085146"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_user_assigned_identity" "test2" {
  name                = "acctestUAI2-231016034356085146"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-mysqlfs-231016034356085146"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "_admin_Terraform_892123456789312"
  administrator_password = "QAZwsx123"
  sku_name               = "B_Standard_B1s"
  zone                   = "2"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id, azurerm_user_assigned_identity.test2.id]
  }
}


resource "azurerm_mysql_flexible_server_active_directory_administrator" "test" {
  server_id   = azurerm_mysql_flexible_server.test.id
  identity_id = azurerm_user_assigned_identity.test.id
  login       = "sqladmin"
  object_id   = data.azurerm_client_config.current.client_id
  tenant_id   = data.azurerm_client_config.current.tenant_id
}


resource "azurerm_mysql_flexible_server_active_directory_administrator" "import" {
  server_id   = azurerm_mysql_flexible_server_active_directory_administrator.test.server_id
  identity_id = azurerm_mysql_flexible_server_active_directory_administrator.test.identity_id
  login       = azurerm_mysql_flexible_server_active_directory_administrator.test.login
  object_id   = azurerm_mysql_flexible_server_active_directory_administrator.test.object_id
  tenant_id   = azurerm_mysql_flexible_server_active_directory_administrator.test.tenant_id
}
