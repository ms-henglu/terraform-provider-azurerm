

provider "azurerm" {
  features {}
}

provider "azuread" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-240311031912859491"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-240311031912859491"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_share" "test" {
  name       = "acctest_ds_240311031912859491"
  account_id = azurerm_data_share_account.test.id
  kind       = "CopyBased"
}

resource "azurerm_storage_account" "test" {
  name                     = "accteststrn49bb"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-240311031912859491"
  storage_account_id = azurerm_storage_account.test.id
}

data "azuread_service_principal" "test" {
  display_name = azurerm_data_share_account.test.name
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = data.azuread_service_principal.test.object_id
}


resource "azurerm_data_share_dataset_data_lake_gen2" "test" {
  name               = "acctest-dlds-240311031912859491"
  share_id           = azurerm_data_share.test.id
  storage_account_id = azurerm_storage_account.test.id
  file_system_name   = azurerm_storage_data_lake_gen2_filesystem.test.name
  folder_path        = "test"
  depends_on = [
    azurerm_role_assignment.test,
  ]
}
