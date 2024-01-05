

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064818070615"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-240105064818070615"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctestAS-240105064818070615"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

resource "azurerm_app_service_slot" "test" {
  name                = "acctestASSlot-240105064818070615"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
  app_service_name    = azurerm_app_service.test.name
}


resource "azurerm_app_service_slot" "import" {
  name                = azurerm_app_service_slot.test.name
  location            = azurerm_app_service_slot.test.location
  resource_group_name = azurerm_app_service_slot.test.resource_group_name
  app_service_plan_id = azurerm_app_service_slot.test.app_service_plan_id
  app_service_name    = azurerm_app_service_slot.test.app_service_name
}
