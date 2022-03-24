
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324161018564829"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsay2972"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-220324161018564829"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  kind                = "elastic"

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}

resource "azurerm_function_app" "test" {
  name                      = "acctest-220324161018564829-func"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  app_service_plan_id       = azurerm_app_service_plan.test.id
  storage_connection_string = azurerm_storage_account.test.primary_connection_string
  version                   = "~3"

  site_config {
    pre_warmed_instance_count        = 1
    runtime_scale_monitoring_enabled = true
  }
}
