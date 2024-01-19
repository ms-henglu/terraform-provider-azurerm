
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-240119024724258228"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240119024724258228"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_container_app_environment" "test" {
  name                = "acctest-CAEnv240119024724258228"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
