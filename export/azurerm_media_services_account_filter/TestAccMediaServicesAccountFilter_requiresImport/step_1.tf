


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-230526085500094447"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1kqvlr"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsakqvlr"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.test.id
    is_primary = true
  }
}


resource "azurerm_media_services_account_filter" "test" {
  name                        = "Filter-1"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
}


resource "azurerm_media_services_account_filter" "import" {
  name                        = azurerm_media_services_account_filter.test.name
  resource_group_name         = azurerm_media_services_account_filter.test.resource_group_name
  media_services_account_name = azurerm_media_services_account_filter.test.media_services_account_name
}
