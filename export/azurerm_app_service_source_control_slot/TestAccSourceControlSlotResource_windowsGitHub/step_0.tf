
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ASSC-230922060536012808"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASSC-230922060536012808"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Windows"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230922060536012808"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_app_service_plan.test.id

  site_config {}
}

resource "azurerm_windows_web_app_slot" "test" {
  name           = "acctestWAS-230922060536012808"
  app_service_id = azurerm_windows_web_app.test.id

  site_config {}
}


resource azurerm_source_control_token test {
  type  = "GitHub"
  token = "ARM_GITHUB_ACCESS_TOKEN"
}

resource "azurerm_app_service_source_control_slot" "test" {
  slot_id  = azurerm_windows_web_app_slot.test.id
  repo_url = "https://github.com/jackofallops/azure-app-service-static-site-tests.git"
  branch   = "main"

  depends_on = [
    azurerm_source_control_token.test,
  ]
}
