
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAEnv-231016033620602059"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestCAEnv-231016033620602059"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv231016033620602059"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_container_app_environment_certificate" "test" {
  name                         = "acctest-cacert231016033620602059"
  container_app_environment_id = azurerm_container_app_environment.test.id
  certificate_blob_base64      = filebase64("testdata/testacc.pfx")
  certificate_password         = "TestAcc"

  tags = {
    env = "testAcc"
  }
}
