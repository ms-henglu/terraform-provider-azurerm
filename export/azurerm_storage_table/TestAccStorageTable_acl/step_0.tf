
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124182408926110"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacci7hrw"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst221124182408926110"
  storage_account_name = azurerm_storage_account.test.name
  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "raud"
      start       = "2020-11-26T08:49:37.0000000Z"
      expiry      = "2020-11-27T08:49:37.0000000Z"
    }
  }
}
