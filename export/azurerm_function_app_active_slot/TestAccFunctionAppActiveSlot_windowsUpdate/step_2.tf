
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024013862991"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa463ui"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-WAS-230825024013862991"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "EP1"
}

resource "azurerm_windows_function_app" "test" {
  name                = "acctestWA-230825024013862991"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  app_settings = {
    WEBSITE_CONTENTSHARE          = "testacc-content-app"
    AzureWebJobsSecretStorageType = "Blob"
  }

  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }

    cors {
      allowed_origins = [
        "https://portal.azure.com",
      ]

      support_credentials = false
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_CONTENTSHARE"],
    ]
  }
}

resource "azurerm_windows_function_app_slot" "test" {
  name                       = "acctest-WFAS-230825024013862991"
  function_app_id            = azurerm_windows_function_app.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  app_settings = {
    WEBSITE_CONTENTSHARE          = "testacc-content-appslot"
    AzureWebJobsSecretStorageType = "Blob"
  }

  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }

    cors {
      allowed_origins = [
        "https://portal.azure.com",
      ]

      support_credentials = false
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_CONTENTSHARE"],
    ]
  }
}


resource "azurerm_windows_function_app_slot" "update" {
  name                       = "acctestWAS2-230825024013862991"
  function_app_id            = azurerm_windows_function_app.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  app_settings = {
    WEBSITE_CONTENTSHARE          = "testacc-content-appslot"
    AzureWebJobsSecretStorageType = "Blob"
  }

  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }

    cors {
      allowed_origins = [
        "https://portal.azure.com",
      ]

      support_credentials = false
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_CONTENTSHARE"],
    ]
  }
}

resource "azurerm_function_app_active_slot" "test" {
  slot_id = azurerm_windows_function_app_slot.update.id
}

