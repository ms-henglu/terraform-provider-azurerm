

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022933549416"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "acctestaccrfzot"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_container" "test" {
  name                  = "test"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}


provider "azurerm" {
  features {}
}

resource "azurerm_storage_blob" "test" {
  name                   = "rick.morty"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Page"
  source_content         = join("", [for i in range(0, 511) : "a"])
}
