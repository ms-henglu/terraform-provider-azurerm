
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230915023301697208"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfirm230915023301697208"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsql230915023301697208"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "ssis_catalog_admin"
  administrator_login_password = "my-s3cret-p4ssword!"
}

resource "azurerm_sql_active_directory_administrator" "test" {
  server_name         = azurerm_sql_server.test.name
  resource_group_name = azurerm_resource_group.test.name
  login               = azurerm_data_factory.test.name
  tenant_id           = azurerm_data_factory.test.identity.0.tenant_id
  object_id           = azurerm_data_factory.test.identity.0.principal_id
}

resource "azurerm_data_factory_integration_runtime_azure_ssis" "test" {
  name            = "managed-integration-runtime"
  data_factory_id = azurerm_data_factory.test.id
  location        = azurerm_resource_group.test.location
  node_size       = "Standard_D8_v3"

  catalog_info {
    server_endpoint = azurerm_sql_server.test.fully_qualified_domain_name
    pricing_tier    = "Basic"
  }

  depends_on = [azurerm_sql_active_directory_administrator.test]
}
