
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031305886871"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "acctestsaud0u1"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "Storage"
  allow_nested_items_to_be_public = true
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-LAS-240311031305886871"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "EP1"
}

resource "azurerm_linux_function_app" "test" {
  name                = "acctestLA-240311031305886871"
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
      python_version = "3.9"
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

resource "azurerm_linux_function_app_slot" "test" {
  name                       = "acctest-LFAS-240311031305886871"
  function_app_id            = azurerm_linux_function_app.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  app_settings = {
    WEBSITE_CONTENTSHARE          = "testacc-content-appslot"
    AzureWebJobsSecretStorageType = "Blob"
  }

  site_config {
    application_stack {
      python_version = "3.9"
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


resource "azurerm_linux_function_app_slot" "update" {
  name                       = "acctestWAS2-240311031305886871"
  function_app_id            = azurerm_linux_function_app.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  app_settings = {
    WEBSITE_CONTENTSHARE          = "testacc-content-appslot"
    AzureWebJobsSecretStorageType = "Blob"
  }

  site_config {
    application_stack {
      python_version = "3.9"
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
  slot_id = azurerm_linux_function_app_slot.update.id
}

