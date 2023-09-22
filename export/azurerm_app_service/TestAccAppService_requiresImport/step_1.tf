

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922062126110482"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230922062126110482"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctestAS-230922062126110482"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}


resource "azurerm_app_service" "import" {
  name                = azurerm_app_service.test.name
  location            = azurerm_app_service.test.location
  resource_group_name = azurerm_app_service.test.resource_group_name
  app_service_plan_id = azurerm_app_service.test.app_service_plan_id
}
