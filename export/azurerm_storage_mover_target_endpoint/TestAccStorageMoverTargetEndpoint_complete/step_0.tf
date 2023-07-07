
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230707004853849512"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "accsai963e"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_container" "test" {
  name                  = "acccontaineri963e"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}

resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-230707004853849512"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_storage_mover_target_endpoint" "test" {
  name                   = "acctest-smte-230707004853849512"
  storage_mover_id       = azurerm_storage_mover.test.id
  storage_account_id     = azurerm_storage_account.test.id
  storage_container_name = azurerm_storage_container.test.name
  description            = "Example Storage Container Endpoint Description"
}
