
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LFA-240112223908935150"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaadg6v"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240112223908935150"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "Y1"
  
}


resource "azurerm_storage_share" "test" {
  name                 = "test"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1
}

resource "azurerm_linux_function_app" "test" {
  name                = "acctest-LFA-240112223908935150"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  app_settings = {
    WEBSITE_CONTENTOVERVNET                  = 1
    WEBSITE_CONTENTSHARE                     = azurerm_storage_share.test.name
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = azurerm_storage_account.test.primary_connection_string
  }

  site_config {}
}
