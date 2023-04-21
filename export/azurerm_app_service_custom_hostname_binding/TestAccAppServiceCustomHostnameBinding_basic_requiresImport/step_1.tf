

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421023120530577"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230421023120530577"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "ARM_TEST_APP_SERVICE"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

resource "azurerm_app_service_custom_hostname_binding" "test" {
  hostname            = "ARM_TEST_DOMAIN"
  app_service_name    = azurerm_app_service.test.name
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_app_service_custom_hostname_binding" "import" {
  hostname            = azurerm_app_service_custom_hostname_binding.test.name
  app_service_name    = azurerm_app_service_custom_hostname_binding.test.app_service_name
  resource_group_name = azurerm_app_service_custom_hostname_binding.test.resource_group_name
}
