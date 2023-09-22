


provider "azurerm" {
  features {}
}

provider "azuread" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-230922054018217982"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-230922054018217982"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_share" "test" {
  name       = "acctest_ds_230922054018217982"
  account_id = azurerm_data_share_account.test.id
  kind       = "CopyBased"
}

resource "azurerm_storage_account" "test" {
  name                     = "accteststrfefu1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230922054018217982"
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
  name               = "acctest-dlds-230922054018217982"
  share_id           = azurerm_data_share.test.id
  storage_account_id = azurerm_storage_account.test.id
  file_system_name   = azurerm_storage_data_lake_gen2_filesystem.test.name
  file_path          = "myfile.txt"
  depends_on = [
    azurerm_role_assignment.test,
  ]
}


resource "azurerm_data_share_dataset_data_lake_gen2" "import" {
  name               = azurerm_data_share_dataset_data_lake_gen2.test.name
  share_id           = azurerm_data_share.test.id
  storage_account_id = azurerm_data_share_dataset_data_lake_gen2.test.storage_account_id
  file_system_name   = azurerm_data_share_dataset_data_lake_gen2.test.file_system_name
  file_path          = azurerm_data_share_dataset_data_lake_gen2.test.file_path
}
