


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-221117231201009447"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa13fe97"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsa3fe97"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.test.id
    is_primary = true
  }
}


resource "azurerm_media_asset" "test" {
  name                        = "Asset-Content1"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
}


resource "azurerm_media_asset" "import" {
  name                        = azurerm_media_asset.test.name
  resource_group_name         = azurerm_media_asset.test.resource_group_name
  media_services_account_name = azurerm_media_asset.test.media_services_account_name
}
