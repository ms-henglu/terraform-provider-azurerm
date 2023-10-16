
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-231016033620609906"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231016033620609906"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_container_app_environment" "test" {
  name                = "acctest-CAEnv231016033620609906"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
