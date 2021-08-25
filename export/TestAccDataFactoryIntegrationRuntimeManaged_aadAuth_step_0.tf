
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210825044702259945"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfirm210825044702259945"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsql210825044702259945"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "ssis_catalog_admin"
  administrator_login_password = "my-s3cret-p4ssword!"
}

data "azuread_service_principal" "test" {
  display_name = azurerm_data_factory.test.name
}

resource "azurerm_sql_active_directory_administrator" "test" {
  server_name         = azurerm_sql_server.test.name
  resource_group_name = azurerm_resource_group.test.name
  login               = azurerm_data_factory.test.name
  tenant_id           = azurerm_data_factory.test.identity.0.tenant_id
  object_id           = data.azuread_service_principal.test.application_id
}

resource "azurerm_data_factory_integration_runtime_managed" "test" {
  name                = "managed-integration-runtime"
  data_factory_name   = azurerm_data_factory.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  node_size           = "Standard_D8_v3"

  catalog_info {
    server_endpoint = azurerm_sql_server.test.fully_qualified_domain_name
    pricing_tier    = "Basic"
  }

  depends_on = [azurerm_sql_active_directory_administrator.test]
}
