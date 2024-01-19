
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119023047616738"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsan2wo8"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-240119023047616738"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "elastic"

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }

  reserved = true
}

resource "azurerm_function_app" "test" {
  name                       = "acctest-240119023047616738-func"
  location                   = azurerm_resource_group.test.location
  version                    = "~1"
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
  os_type                    = "linux"

}
