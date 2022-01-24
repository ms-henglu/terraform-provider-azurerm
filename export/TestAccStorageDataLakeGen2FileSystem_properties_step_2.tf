

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124125733243726"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacckl6x0"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}


resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-220124125733243726"
  storage_account_id = azurerm_storage_account.test.id

  properties = {
    key = "ZXll"
  }
}
