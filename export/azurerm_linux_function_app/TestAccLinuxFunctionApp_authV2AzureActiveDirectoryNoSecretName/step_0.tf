
provider "azurerm" {
  features {}
}

provider "azuread" {}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LFA-240311031305881512"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaurpjw"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240311031305881512"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "B1"
  
}


data "azurerm_client_config" "current" {}

resource "azurerm_linux_function_app" "test" {
  name                = "acctest-LFA-240311031305881512"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}


  auth_settings_v2 {
    auth_enabled           = true
    unauthenticated_action = "Return401"
    active_directory_v2 {
      client_id            = data.azurerm_client_config.current.client_id
      tenant_auth_endpoint = "https://sts.windows.net/ARM_TENANT_ID/v2.0"
    }

    login {
      token_store_enabled = true
    }
  }
}
