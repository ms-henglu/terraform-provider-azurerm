
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-240105063154023624"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestasscz7y8"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "assbackup"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  container_name    = azurerm_storage_container.test.name
  https_only        = true

  start  = "2018-06-01"
  expiry = "2048-06-01"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

resource "azurerm_analysis_services_server" "test" {
  name                = "acctestass240105063154023624"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "B1"

  backup_blob_container_uri = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}${data.azurerm_storage_account_blob_container_sas.test.sas}"
}
