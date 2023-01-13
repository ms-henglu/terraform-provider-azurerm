

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-230113181415765381"
  location = "West Europe"
}

resource "azurerm_storage_account" "first" {
  name                     = "acctestsa1g88no"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


resource "azurerm_media_services_account" "test" {
  name                = "acctestmsag88no"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  storage_account {
    id         = azurerm_storage_account.first.id
    is_primary = true
  }
  identity {
    type = "SystemAssigned"
  }
  tags = {
    environment = "staging"
  }
}
