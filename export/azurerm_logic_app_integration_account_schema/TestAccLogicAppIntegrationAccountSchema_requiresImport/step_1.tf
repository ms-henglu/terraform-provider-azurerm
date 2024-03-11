


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-240311032431483148"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-240311032431483148"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_logic_app_integration_account_schema" "test" {
  name                     = "acctest-iaschema-240311032431483148"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  content                  = file("testdata/integration_account_schema_content.xsd")
}


resource "azurerm_logic_app_integration_account_schema" "import" {
  name                     = azurerm_logic_app_integration_account_schema.test.name
  resource_group_name      = azurerm_logic_app_integration_account_schema.test.resource_group_name
  integration_account_name = azurerm_logic_app_integration_account_schema.test.integration_account_name
  content                  = azurerm_logic_app_integration_account_schema.test.content
}
