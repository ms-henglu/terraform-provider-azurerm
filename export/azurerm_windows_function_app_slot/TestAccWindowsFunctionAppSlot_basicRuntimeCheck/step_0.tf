
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-WFA-221111013056111145"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsazq3o3"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-221111013056111145"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "EP1"
  maximum_elastic_worker_count = 5
}

resource "azurerm_windows_function_app" "test" {
  name                = "acctest-WFA-221111013056111145"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}
}


resource "azurerm_windows_function_app_slot" "test" {
  name                       = "acctest-WFAS-221111013056111145"
  function_app_id            = azurerm_windows_function_app.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {
    runtime_scale_monitoring_enabled = true
  }
}
