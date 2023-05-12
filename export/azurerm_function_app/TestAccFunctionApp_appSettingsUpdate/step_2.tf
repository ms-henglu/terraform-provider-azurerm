
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011608522643"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaiix3u"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230512011608522643"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "test" {
  name                       = "acctest-230512011608522643-func"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  app_settings = {
    "hello"                   = "world"
    "WEBSITE_VNET_ROUTE_ALL"  = "true"
    "WEBSITE_CONTENTOVERVNET" = "true"
    "WEBSITE_DNS_SERVER"      = "1.1.1.1"
  }
}
