
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-240119025436798842"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acctuhdbc"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_virtual_machine_group" "test" {
  name                = "acctestaguhdbc"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sql_image_offer     = "SQL2017-WS2016"
  sql_image_sku       = "Developer"

  wsfc_domain_profile {
    fqdn                        = "testdomain.com"
    storage_account_url         = azurerm_storage_account.test.primary_blob_endpoint
    storage_account_primary_key = azurerm_storage_account.test.primary_access_key
    cluster_subnet_type         = "SingleSubnet"
  }
}
