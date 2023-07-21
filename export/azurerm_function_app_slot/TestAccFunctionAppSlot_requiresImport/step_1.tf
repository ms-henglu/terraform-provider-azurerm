

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721020250720962"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230721020250720962"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsahesm8"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "test" {
  name                       = "acctestFA-230721020250720962"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
}

resource "azurerm_function_app_slot" "test" {
  name                       = "acctestFASlot-230721020250720962"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  function_app_name          = azurerm_function_app.test.name
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
}


resource "azurerm_function_app_slot" "import" {
  name                       = azurerm_function_app_slot.test.name
  location                   = azurerm_function_app_slot.test.location
  resource_group_name        = azurerm_function_app_slot.test.resource_group_name
  app_service_plan_id        = azurerm_function_app_slot.test.app_service_plan_id
  function_app_name          = azurerm_function_app_slot.test.function_app_name
  storage_account_name       = azurerm_function_app_slot.test.storage_account_name
  storage_account_access_key = azurerm_function_app_slot.test.storage_account_access_key
}
