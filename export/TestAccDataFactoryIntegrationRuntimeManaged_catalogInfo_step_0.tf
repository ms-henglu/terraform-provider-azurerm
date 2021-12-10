
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211210034558574007"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfirm211210034558574007"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsql211210034558574007"
  resource_group_name          = "${azurerm_resource_group.test.name}"
  location                     = "${azurerm_resource_group.test.location}"
  version                      = "12.0"
  administrator_login          = "ssis_catalog_admin"
  administrator_login_password = "my-s3cret-p4ssword!"
}

resource "azurerm_data_factory_integration_runtime_managed" "test" {
  name                = "managed-integration-runtime"
  data_factory_name   = azurerm_data_factory.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  node_size = "Standard_D8_v3"

  catalog_info {
    server_endpoint        = "${azurerm_sql_server.test.fully_qualified_domain_name}"
    administrator_login    = "ssis_catalog_admin"
    administrator_password = "my-s3cret-p4ssword!"
    pricing_tier           = "Basic"
  }
}
