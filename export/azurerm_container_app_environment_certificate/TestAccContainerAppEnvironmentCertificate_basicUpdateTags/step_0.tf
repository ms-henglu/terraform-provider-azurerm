
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAEnv-230915023123084036"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestCAEnv-230915023123084036"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv230915023123084036"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_container_app_environment_certificate" "test" {
  name                         = "acctest-cacert230915023123084036"
  container_app_environment_id = azurerm_container_app_environment.test.id
  certificate_blob_base64      = filebase64("testdata/testacc.pfx")
  certificate_password         = "TestAcc"
}
