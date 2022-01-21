
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121045136637246"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa0hgfu"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-220121045136637246"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  kind                = "elastic"

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}

resource "azurerm_function_app" "test" {
  name                      = "acctest-220121045136637246-func"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  app_service_plan_id       = azurerm_app_service_plan.test.id
  storage_connection_string = azurerm_storage_account.test.primary_connection_string

  site_config {
    app_scale_limit = 1
  }
}
