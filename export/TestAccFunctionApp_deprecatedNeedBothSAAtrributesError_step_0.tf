
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225035153494901"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsai36vo"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-220225035153494901"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "test" {
  name                 = "acctest-220225035153494901-func"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  app_service_plan_id  = azurerm_app_service_plan.test.id
  storage_account_name = azurerm_storage_account.test.name
}
