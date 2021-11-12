


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-211112020922668598"
  location = "West Europe"
}

resource "azurerm_storage_account" "first" {
  name                     = "acctestsa13zfi7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


resource "azurerm_media_services_account" "test" {
  name                = "acctestmsa3zfi7"
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


resource "azurerm_media_services_account" "import" {
  name                = azurerm_media_services_account.test.name
  location            = azurerm_media_services_account.test.location
  resource_group_name = azurerm_media_services_account.test.resource_group_name

  storage_account {
    id         = azurerm_storage_account.first.id
    is_primary = true
  }

  tags = {
    environment = "staging"
  }
}
