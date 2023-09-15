



provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-230915023123085594"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230915023123085594"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_container_app_environment" "test" {
  name                = "acctest-CAEnv230915023123085594"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_container_app_environment" "import" {
  name                = azurerm_container_app_environment.test.name
  resource_group_name = azurerm_container_app_environment.test.resource_group_name
  location            = azurerm_container_app_environment.test.location
}
