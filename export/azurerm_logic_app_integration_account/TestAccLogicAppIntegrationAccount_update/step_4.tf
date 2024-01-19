

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-240119025300903777"
  location = "West Europe"
}


resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-IA-240119025300903777"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
  tags = {
    ENV = "Stage"
  }
}
