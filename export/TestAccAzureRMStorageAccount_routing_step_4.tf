
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220826003347760474"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2accttmx3q"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  routing {
    choice                     = "MicrosoftRouting"
    publish_internet_endpoints = true
  }

  tags = {
    environment = "production"
  }
}
