

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-221221204554670497"
  location = "West Europe"
}

resource "azurerm_storage_account" "first" {
  name                     = "acctestsa1v0uir"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


resource "azurerm_storage_account" "second" {
  name                     = "acctestsa2v0uir"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsav0uir"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.second.id
    is_primary = false
  }

  storage_account {
    id         = azurerm_storage_account.first.id
    is_primary = true
  }
}
