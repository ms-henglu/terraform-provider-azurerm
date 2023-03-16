

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230316221814605159"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-230316221814605159"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_logic_app_integration_account_map" "test" {
  name                     = "acctest-iamap-230316221814605159"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  map_type                 = "Xslt20"
  content                  = file("testdata/integration_account_map_content2.xsd")

  metadata = {
    foo = "bar2"
  }
}
