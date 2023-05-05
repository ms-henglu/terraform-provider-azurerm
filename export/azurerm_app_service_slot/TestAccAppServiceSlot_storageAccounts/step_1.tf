
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505051515551656"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230505051515551656"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "acct230505051515551656"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctestcontainer"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_storage_share" "test" {
  name                 = "acctestshare"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1
}

resource "azurerm_app_service" "test" {
  name                = "acctestAS-230505051515551656"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

resource "azurerm_app_service_slot" "test" {
  name                = "acctestASSlot-230505051515551656"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
  app_service_name    = azurerm_app_service.test.name

  storage_account {
    name         = "blobs"
    type         = "AzureBlob"
    account_name = azurerm_storage_account.test.name
    share_name   = azurerm_storage_container.test.name
    access_key   = azurerm_storage_account.test.primary_access_key
    mount_path   = "/blobs"
  }

  storage_account {
    name         = "files"
    type         = "AzureFiles"
    account_name = azurerm_storage_account.test.name
    share_name   = azurerm_storage_share.test.name
    access_key   = azurerm_storage_account.test.primary_access_key
    mount_path   = "/files"
  }
}
