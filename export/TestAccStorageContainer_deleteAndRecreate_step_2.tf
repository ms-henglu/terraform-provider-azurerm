
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072438443026"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacckt8fq"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true

  tags = {
    environment = "staging"
  }
}
