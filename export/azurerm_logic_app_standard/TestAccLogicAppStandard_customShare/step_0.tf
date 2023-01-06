
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106034653899158"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa17dln"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230106034653899158"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "elastic"

  sku {
    tier = "WorkflowStandard"
    size = "WS1"
  }
}


resource "azurerm_storage_share" "custom" {
  name                 = "customshare"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1
}

resource "azurerm_logic_app_standard" "test" {
  name                       = "acctest-230106034653899158-func"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
  storage_account_share_name = azurerm_storage_share.custom.name

  app_settings = {
    "hello"                          = "world"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_storage_account.test.primary_connection_string
  }
}
