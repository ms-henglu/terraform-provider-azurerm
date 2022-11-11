
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014426382989"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-221111014426382989"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}
