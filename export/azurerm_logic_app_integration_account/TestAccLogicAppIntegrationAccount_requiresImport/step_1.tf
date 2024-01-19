


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-240119025300906426"
  location = "West Europe"
}


resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-IA-240119025300906426"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_logic_app_integration_account" "import" {
  name                = azurerm_logic_app_integration_account.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = azurerm_logic_app_integration_account.test.sku_name
}
