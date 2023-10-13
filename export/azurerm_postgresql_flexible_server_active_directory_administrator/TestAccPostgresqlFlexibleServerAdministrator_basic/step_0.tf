
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "current" {}

data "azuread_service_principal" "test" {
  object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-231013044050507343"
  location = "West Europe"
}

resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-231013044050507343"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  storage_mb             = 32768
  version                = "12"
  sku_name               = "GP_Standard_D2s_v3"
  zone                   = "2"

  authentication {
    active_directory_auth_enabled = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "test" {
  server_name         = azurerm_postgresql_flexible_server.test.name
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_service_principal.test.object_id
  principal_name      = data.azuread_service_principal.test.display_name
  principal_type      = "ServicePrincipal"
}
