
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-240119025151967186"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acc240119025151967186"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "acctestcont"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-240119025151967186"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}

resource "azurerm_iothub_endpoint_storage_container" "test" {
  resource_group_name = azurerm_resource_group.test.name
  iothub_id           = azurerm_iothub.test.id
  name                = "acctest"

  container_name    = "acctestcont"
  connection_string = azurerm_storage_account.test.primary_blob_connection_string
}
