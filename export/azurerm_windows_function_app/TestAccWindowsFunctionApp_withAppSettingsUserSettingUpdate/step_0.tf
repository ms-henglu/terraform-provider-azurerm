
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-WFA-240119024436511881"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa6w0my"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240119024436511881"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "Y1"
  
}


resource "azurerm_windows_function_app" "test" {
  name                = "acctest-WFA-240119024436511881"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  app_settings = {}

  site_config {}
}
