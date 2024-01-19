

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-240119025405112576"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1modw8"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsamodw8"
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
