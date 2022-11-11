

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-221111013907377504"
  location = "West Europe"
}

resource "azurerm_storage_account" "first" {
  name                     = "acctestsa1r7kn9"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


resource "azurerm_media_services_account" "test" {
  name                = "acctestmsar7kn9"
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
