
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-231218071451552573"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231218071451552573"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-231218071451552573"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_container_app_environment" "test" {
  name                = "acctest-CAEnv231218071451552573"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  dapr_application_insights_connection_string = azurerm_application_insights.test.connection_string
}
