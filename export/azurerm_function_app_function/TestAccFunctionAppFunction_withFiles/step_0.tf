
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LFA-231016033329277907"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa3etxw"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-231016033329277907"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_windows_function_app" "test" {
  name                = "acctest-WFA-231016033329277907"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }
  }
}


resource "azurerm_function_app_function" "test" {
  name            = "testAcc-FnAppFn-231016033329277907"
  function_app_id = azurerm_windows_function_app.test.id
  language        = "CSharp"
  file {
    name    = "run.csx"
    content = file("testdata/run.csx")
  }
  test_data = jsonencode({
    "name" = "Azure"
  })
  config_json = jsonencode({
    "bindings" = [
      {
        "authLevel" = "function"
        "direction" = "in"
        "methods" = [
          "get",
          "post",
        ]
        "name" = "req"
        "type" = "httpTrigger"
      },
      {
        "direction" = "out"
        "name"      = "$return"
        "type"      = "http"
      },
    ]
  })
}
