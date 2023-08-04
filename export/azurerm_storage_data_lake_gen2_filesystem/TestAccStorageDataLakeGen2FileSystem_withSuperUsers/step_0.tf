

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030801233292"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccvkk47"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}


provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa230804030801233292"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230804030801233292"
  storage_account_id = azurerm_storage_account.test.id
  owner              = "$superuser"
  group              = "$superuser"
}
