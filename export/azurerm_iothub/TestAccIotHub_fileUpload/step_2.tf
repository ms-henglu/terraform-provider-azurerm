
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032307929550"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsarinel"
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
  name                = "acctestIoTHub-240311032307929550"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  file_upload {
    connection_string  = azurerm_storage_account.test.primary_blob_connection_string
    container_name     = azurerm_storage_container.test.name
    notifications      = true
    max_delivery_count = 12
    sas_ttl            = "PT2H"
    default_ttl        = "PT3H"
    lock_duration      = "PT5M"
  }
}
