

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-240119024414837047"
  location = "West Europe"
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_resource_group.test.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf240119024414837047"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
  depends_on = [
    azurerm_role_assignment.test,
  ]
}


resource "azurerm_app_configuration_key" "test" {
  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "acctest-ackey-240119024414837047/Label/AppConfigurationKey/Label/"
  content_type           = "test"
  label                  = "/AppConfigurationKey/acctest-ackeylabel-240119024414837047"
  value                  = "a test"
}
