

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311033236890307"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccjiye2"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_container" "test" {
  name                  = "$root"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}
