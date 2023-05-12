
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-conn-230512003634417063"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-conn-230512003634417063"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestsbn-conn-230512003634417063"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

data "azurerm_managed_api" "test" {
  name     = "servicebus"
  location = azurerm_resource_group.test.location
}


resource "azurerm_api_connection" "test" {
  name                = "acctestconn-230512003634417063"
  resource_group_name = azurerm_resource_group.test.name
  managed_api_id      = data.azurerm_managed_api.test.id
}
