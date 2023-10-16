
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-WFA-231016033329378791"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsas4wqu"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-231016033329378791"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
  
}

resource "azurerm_windows_function_app" "test" {
  name                = "acctest-WFA-231016033329378791"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acct-231016033329378791"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}




resource "azurerm_user_assigned_identity" "kv" {
  name                = "acctest-kv-231016033329378791"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_windows_function_app_slot" "test" {
  name                       = "acctest-WFAS-231016033329378791"
  function_app_id            = azurerm_windows_function_app.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id, azurerm_user_assigned_identity.kv.id]
  }

  key_vault_reference_identity_id = azurerm_user_assigned_identity.kv.id
}
