

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-conn-230922060816845387"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-conn-230922060816845387"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestsbn-conn-230922060816845387"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

data "azurerm_managed_api" "test" {
  name     = "servicebus"
  location = azurerm_resource_group.test.location
}


resource "azurerm_api_connection" "test" {
  name                = "acctestconn-230922060816845387"
  resource_group_name = azurerm_resource_group.test.name
  managed_api_id      = data.azurerm_managed_api.test.id
}


resource "azurerm_api_connection" "import" {
  name                = azurerm_api_connection.test.name
  resource_group_name = azurerm_api_connection.test.resource_group_name
  managed_api_id      = azurerm_api_connection.test.managed_api_id
}
