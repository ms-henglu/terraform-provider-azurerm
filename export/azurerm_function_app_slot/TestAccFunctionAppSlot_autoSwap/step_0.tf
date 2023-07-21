
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721012624257472"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230721012624257472"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "elastic"

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa7zc39"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "test" {
  name                       = "acctestFA-230721012624257472"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
  version                    = "~3"
}

resource "azurerm_function_app_slot" "test" {
  name                       = "acctestFASlot-230721012624257472"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  function_app_name          = azurerm_function_app.test.name
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
  version                    = "~3"

  site_config {
    auto_swap_slot_name = "production"
  }
}
