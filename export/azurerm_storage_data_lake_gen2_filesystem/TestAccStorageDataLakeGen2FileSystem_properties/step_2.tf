

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112035239898477"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccfh0xj"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}


resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-240112035239898477"
  storage_account_id = azurerm_storage_account.test.id

  properties = {
    key = "ZXll"
  }
}
