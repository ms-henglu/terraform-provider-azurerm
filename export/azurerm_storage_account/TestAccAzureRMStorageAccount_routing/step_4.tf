
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240119025908574870"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acctptzhi"
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
