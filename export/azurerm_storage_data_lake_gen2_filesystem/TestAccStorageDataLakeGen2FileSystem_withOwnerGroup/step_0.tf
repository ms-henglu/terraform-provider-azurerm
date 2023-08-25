

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025402587229"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc1sldw"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}


provider "azuread" {}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "storage_blob_owner" {
  role_definition_name = "Storage Blob Data Owner"
  scope                = azurerm_resource_group.test.id
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azuread_application" "test" {
  display_name = "acctestspa230825025402587229"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230825025402587229"
  storage_account_id = azurerm_storage_account.test.id
  owner              = azuread_service_principal.test.object_id
  group              = azuread_service_principal.test.object_id
}
