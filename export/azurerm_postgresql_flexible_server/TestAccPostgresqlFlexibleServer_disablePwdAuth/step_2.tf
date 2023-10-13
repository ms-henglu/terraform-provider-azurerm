

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-231013044050510131"
  location = "West Europe"
}


data "azurerm_client_config" "current" {
}

resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-231013044050510131"
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
    password_auth_enabled         = false
   tenant_id = data.azurerm_client_config.current.tenant_id
  }

}
