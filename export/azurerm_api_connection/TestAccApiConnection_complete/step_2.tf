
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-conn-240112224140240930"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-conn-240112224140240930"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestsbn-conn-240112224140240930"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

data "azurerm_managed_api" "test" {
  name     = "servicebus"
  location = azurerm_resource_group.test.location
}


resource "azurerm_api_connection" "test" {
  name                = "acctestconn-240112224140240930"
  resource_group_name = azurerm_resource_group.test.name
  managed_api_id      = data.azurerm_managed_api.test.id
  display_name        = "Example 1"

  parameter_values = {
    connectionString = azurerm_servicebus_namespace.test.default_primary_connection_string
  }

  tags = {
    Another = "Tag"
    Hello   = "World"
  }

  lifecycle {
    ignore_changes = ["parameter_values"] # not returned from the API
  }
}
