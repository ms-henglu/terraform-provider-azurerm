

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020042050883796"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-231020042050883796"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Linux"

  sku {
    tier = "Basic"
    size = "B1"
  }

  reserved = true
}


resource "azurerm_app_service_plan" "import" {
  name                = azurerm_app_service_plan.test.name
  location            = azurerm_app_service_plan.test.location
  resource_group_name = azurerm_app_service_plan.test.resource_group_name
  kind                = azurerm_app_service_plan.test.kind

  sku {
    tier = "Basic"
    size = "B1"
  }

  reserved = true
}
