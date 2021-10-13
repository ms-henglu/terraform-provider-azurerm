

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-211013072040879823"
  location = "West Europe"
}


resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-IA-211013072040879823"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
  tags = {
    ENV = "Test"
  }
}
