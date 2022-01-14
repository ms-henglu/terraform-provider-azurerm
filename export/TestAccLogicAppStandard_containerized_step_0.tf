
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114014418345218"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa36788"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-220114014418345218"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "elastic"
  reserved            = true

  sku {
    tier = "WorkflowStandard"
    size = "WS1"
  }
}


resource "azurerm_logic_app_standard" "test" {
  name                       = "acctest-220114014418345218-func"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {
    linux_fx_version = "DOCKER|mcr.microsoft.com/azure-functions/dotnet:3.0-appservice"
  }
}
