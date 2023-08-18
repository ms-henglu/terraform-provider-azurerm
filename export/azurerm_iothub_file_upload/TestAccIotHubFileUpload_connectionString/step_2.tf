

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818024155757505"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsag9mg0"
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
  name                = "acctestIoTHub-230818024155757505"
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


resource "azurerm_storage_account" "test2" {
  name                     = "acctestsa2g9mg0"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test2" {
  name                  = "test"
  storage_account_name  = azurerm_storage_account.test2.name
  container_access_type = "private"
}

resource "azurerm_iothub_file_upload" "test" {
  iothub_id         = azurerm_iothub.test.id
  connection_string = azurerm_storage_account.test2.primary_blob_connection_string
  container_name    = azurerm_storage_container.test2.name
}
