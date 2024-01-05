

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063949008543"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaggwyo"
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
  name                = "acctestIoTHub-240105063949008543"
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

  max_delivery_count = 12
}
