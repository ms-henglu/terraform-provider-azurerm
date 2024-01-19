


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-240119025405132170"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa14xlg1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsa4xlg1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.test.id
    is_primary = true
  }
}

resource "azurerm_media_asset" "test" {
  name                        = "test"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
}


resource "azurerm_media_streaming_policy" "test" {
  name                        = "Policy-1"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  no_encryption_enabled_protocols {
    download         = true
    dash             = true
    hls              = true
    smooth_streaming = true
  }
}


resource "azurerm_media_streaming_policy" "import" {
  name                        = azurerm_media_streaming_policy.test.name
  resource_group_name         = azurerm_media_streaming_policy.test.resource_group_name
  media_services_account_name = azurerm_media_streaming_policy.test.media_services_account_name
  no_encryption_enabled_protocols {
    download         = true
    dash             = true
    hls              = true
    smooth_streaming = true
  }
}
