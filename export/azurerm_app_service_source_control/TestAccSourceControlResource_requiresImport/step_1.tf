

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ASSC-240112223909004722"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctest-SP-240112223909004722"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "S1"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-240112223909004722"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_app_service_source_control" "test" {
  app_id                 = azurerm_windows_web_app.test.id
  repo_url               = "https://github.com/Azure-Samples/app-service-web-dotnet-get-started.git"
  branch                 = "master"
  use_manual_integration = true
}


resource "azurerm_app_service_source_control" "import" {
  app_id                 = azurerm_app_service_source_control.test.app_id
  repo_url               = azurerm_app_service_source_control.test.repo_url
  branch                 = azurerm_app_service_source_control.test.branch
  use_manual_integration = azurerm_app_service_source_control.test.use_manual_integration
}
