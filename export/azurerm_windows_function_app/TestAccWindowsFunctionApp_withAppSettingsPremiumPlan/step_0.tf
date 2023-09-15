
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-WFA-230915022839938717"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsah3v1f"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230915022839938717"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "P1v2"
  
}


resource "azurerm_windows_function_app" "test" {
  name                = "acctest-WFA-230915022839938717"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  app_settings = {
    foo    = "bar"
    secret = "sauce"
  }

  site_config {}
}
