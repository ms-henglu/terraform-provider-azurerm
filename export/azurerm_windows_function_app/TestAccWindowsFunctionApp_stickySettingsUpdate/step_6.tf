
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-WFA-240119021457861205"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsadc0h9"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240119021457861205"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
  
}


resource "azurerm_windows_function_app" "test" {
  name                = "acctest-WFA-240119021457861205"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
  site_config {}

  app_settings = {
    foo                                     = "bar"
    secret                                  = "sauce"
    third                                   = "degree"
    "Special chars: !@#$%^&*()_+-=' \";/?" = "Supported by the Azure portal"
  }

  connection_string {
    name  = "First"
    value = "first-connection-string"
    type  = "Custom"
  }

  connection_string {
    name  = "Second"
    value = "some-postgresql-connection-string"
    type  = "PostgreSQL"
  }

  connection_string {
    name  = "Third"
    value = "some-postgresql-connection-string"
    type  = "PostgreSQL"
  }

  connection_string {
    name  = "Special chars: !@#$%^&*()_+-=' \";/?"
    value = "characters-supported-by-the-Azure-portal"
    type  = "Custom"
  }

  sticky_settings {
    app_setting_names       = ["foo", "secret", "Special chars: !@#$%^&*()_+-=' \";/?"]
    connection_string_names = ["First", "Third", "Special chars: !@#$%^&*()_+-=' \";/?"]
  }
}
