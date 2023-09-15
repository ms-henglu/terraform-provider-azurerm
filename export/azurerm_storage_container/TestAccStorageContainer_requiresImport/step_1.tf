


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024302440233"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "acctestacccr0et"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}


resource "azurerm_storage_container" "import" {
  name                  = azurerm_storage_container.test.name
  storage_account_name  = azurerm_storage_container.test.storage_account_name
  container_access_type = azurerm_storage_container.test.container_access_type
}
