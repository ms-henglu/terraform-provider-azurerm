

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726015328233636"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc83xda"
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
  display_name = "acctestspa220726015328233636"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-220726015328233636"
  storage_account_id = azurerm_storage_account.test.id
  owner              = azuread_service_principal.test.object_id
  group              = azuread_service_principal.test.object_id
}
