
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LFA-230512010204395773"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa8m6lu"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230512010204395773"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "S1"
  
}

resource "azurerm_linux_function_app" "test" {
  name                = "acctest-LFA-230512010204395773"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acct-230512010204395773"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}



resource "azurerm_user_assigned_identity" "kv" {
  name                = "acctest-kv-230512010204395773"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_linux_function_app_slot" "test" {
  name                       = "acctest-LFAS-230512010204395773"
  function_app_id            = azurerm_linux_function_app.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id, azurerm_user_assigned_identity.kv.id]
  }

  key_vault_reference_identity_id = azurerm_user_assigned_identity.kv.id
}
