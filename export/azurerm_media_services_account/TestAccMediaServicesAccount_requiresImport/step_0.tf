

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-230120054855354129"
  location = "West Europe"
}

resource "azurerm_storage_account" "first" {
  name                     = "acctestsa18x9u7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


resource "azurerm_media_services_account" "test" {
  name                = "acctestmsa8x9u7"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.first.id
    is_primary = true
  }

  tags = {
    environment = "staging"
  }
}
