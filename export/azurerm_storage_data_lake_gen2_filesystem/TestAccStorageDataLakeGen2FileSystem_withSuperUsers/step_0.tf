

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204913354199"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccmfqwg"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}


provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa221221204913354199"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-221221204913354199"
  storage_account_id = azurerm_storage_account.test.id
  owner              = "$superuser"
  group              = "$superuser"
}
