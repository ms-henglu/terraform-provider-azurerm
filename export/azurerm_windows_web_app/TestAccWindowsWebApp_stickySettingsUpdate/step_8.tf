
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064322439071"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230929064322439071"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230929064322439071"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}

  app_settings = {
    foo    = "bar"
    secret = "sauce"
    third  = "degree"
  }

  connection_string {
    name  = "First"
    value = "first-connection-string"
    type  = "Custom"
  }

  connection_string {
    name  = "Second"
    value = "some-postgresql-connection-string"
    type  = "PostgreSQL"
  }

  connection_string {
    name  = "Third"
    value = "some-postgresql-connection-string"
    type  = "PostgreSQL"
  }
}
