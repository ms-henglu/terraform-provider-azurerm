
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014429871894"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsanio23"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-211015014429871894"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_logic_app_standard" "test" {
  name                       = "acctest-211015014429871894-func"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  version = "~1"

  site_config {
    dotnet_framework_version = "v4.0"
  }
}
