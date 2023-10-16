

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-231016034206844593"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-231016034206844593"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_logic_app_integration_account_map" "test" {
  name                     = "acctest-iamap-231016034206844593"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  map_type                 = "Liquid"
  content                  = file("testdata/integration_account_map_content.liquid")

  metadata = {
    foo = "bar"
  }
}
