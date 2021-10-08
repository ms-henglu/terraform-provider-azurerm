
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008045101871053"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsak86k6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-211008045101871053"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  kind                = "elastic"

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}

resource "azurerm_function_app" "test" {
  name                      = "acctest-211008045101871053-func"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  app_service_plan_id       = azurerm_app_service_plan.test.id
  storage_connection_string = azurerm_storage_account.test.primary_connection_string
}
