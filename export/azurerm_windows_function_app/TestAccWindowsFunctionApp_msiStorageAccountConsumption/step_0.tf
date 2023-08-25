
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-WFA-230825024013944751"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1xu6x"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230825024013944751"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "Y1"
  
}



resource "azurerm_role_assignment" "func_app_access_to_storage" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_windows_function_app.test.identity[0].principal_id
}

resource "azurerm_windows_function_app" "test" {
  name                = "acctest-WFA-230825024013944751"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name          = azurerm_storage_account.test.name
  storage_uses_managed_identity = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }
  }
}
