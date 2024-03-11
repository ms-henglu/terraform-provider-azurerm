


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-240311032431483550"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-240311032431483550"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_logic_app_integration_account_session" "test" {
  name                     = "acctest-ias-240311032431483550"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name

  content = <<CONTENT
	{
       "controlNumber": "1234"
    }
  CONTENT
}


resource "azurerm_logic_app_integration_account_session" "import" {
  name                     = azurerm_logic_app_integration_account_session.test.name
  resource_group_name      = azurerm_logic_app_integration_account_session.test.resource_group_name
  integration_account_name = azurerm_logic_app_integration_account_session.test.integration_account_name
  content                  = azurerm_logic_app_integration_account_session.test.content
}
