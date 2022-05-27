

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-220527034343693503"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-220527034343693503"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_logic_app_integration_account_session" "test" {
  name                     = "acctest-ias-220527034343693503"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name

  content = <<CONTENT
	{
       "controlNumber": "1234"
    }
  CONTENT
}
