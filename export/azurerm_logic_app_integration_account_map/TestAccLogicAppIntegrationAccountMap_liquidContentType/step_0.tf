

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-221117231108754467"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-221117231108754467"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_logic_app_integration_account_map" "test" {
  name                     = "acctest-iamap-221117231108754467"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  map_type                 = "Liquid"
  content                  = file("testdata/integration_account_map_content.liquid")

  metadata = {
    foo = "bar"
  }
}
