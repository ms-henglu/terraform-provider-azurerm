

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015015211283411"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccw9n3l"
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
  name                  = "$web"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}
