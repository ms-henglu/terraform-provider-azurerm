
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ASSC-230825024013938054"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASSC-230825024013938054"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Windows"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230825024013938054"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_app_service_plan.test.id

  site_config {}
}

resource "azurerm_windows_web_app_slot" "test" {
  name           = "acctestWAS-230825024013938054"
  app_service_id = azurerm_windows_web_app.test.id

  site_config {}
}


resource azurerm_source_control_token test {
  type  = "GitHub"
  token = "ARM_GITHUB_ACCESS_TOKEN"
}

resource "azurerm_app_service_source_control_slot" "test" {
  slot_id  = azurerm_windows_web_app.test.id
  repo_url = "https://github.com/Azure-Samples/app-service-web-dotnet-get-started.git"
  branch   = "master"

  github_action_configuration {
    generate_workflow_file = true

    code_configuration {
      runtime_stack   = "dotnetcore"
      runtime_version = "5.0.x"
    }
  }
}
