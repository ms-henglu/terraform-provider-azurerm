
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127045643560179"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsab7btz"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230127045643560179"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "elastic"

  sku {
    tier = "WorkflowStandard"
    size = "WS1"
  }
}


resource "azurerm_logic_app_standard" "test" {
  name                       = "acctest-230127045643560179-func"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  version = "~3"

  site_config {
    dotnet_framework_version = "v5.0"
  }
}
