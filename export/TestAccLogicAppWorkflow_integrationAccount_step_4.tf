
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-211013072040896922"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-IA-211013072040896922"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_logic_app_integration_account" "test2" {
  name                = "acctest-IA2-211013072040896922"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_logic_app_workflow" "test" {
  name                             = "acctestlaw-211013072040896922"
  location                         = azurerm_resource_group.test.location
  resource_group_name              = azurerm_resource_group.test.name
  logic_app_integration_account_id = azurerm_logic_app_integration_account.test2.id
}
