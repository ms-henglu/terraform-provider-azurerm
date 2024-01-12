


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034527587104"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsar2saq"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "test"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-240112034527587104"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  lifecycle {
    ignore_changes = [
      file_upload
    ]
  }
}


resource "azurerm_iothub_file_upload" "test" {
  iothub_id         = azurerm_iothub.test.id
  connection_string = azurerm_storage_account.test.primary_blob_connection_string
  container_name    = azurerm_storage_container.test.name
}


resource "azurerm_iothub_file_upload" "import" {
  iothub_id         = azurerm_iothub_file_upload.test.iothub_id
  connection_string = azurerm_iothub_file_upload.test.connection_string
  container_name    = azurerm_iothub_file_upload.test.container_name
}
