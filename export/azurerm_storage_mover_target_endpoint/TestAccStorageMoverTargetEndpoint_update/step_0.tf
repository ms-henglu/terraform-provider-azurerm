
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230616075546541562"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "accsa3vk4c"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_container" "test" {
  name                  = "acccontainer3vk4c"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}

resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-230616075546541562"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_storage_mover_target_endpoint" "test" {
  name                   = "acctest-smte-230616075546541562"
  storage_mover_id       = azurerm_storage_mover.test.id
  storage_account_id     = azurerm_storage_account.test.id
  storage_container_name = azurerm_storage_container.test.name
  description            = "Example Storage Container Endpoint Description"
}
