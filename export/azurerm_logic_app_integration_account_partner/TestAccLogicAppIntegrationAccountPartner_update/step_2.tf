

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230915023656667889"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-230915023656667889"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_partner" "test" {
  name                     = "acctest-iap-230915023656667889"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name

  business_identity {
    qualifier = "AS2Identity"
    value     = "FabrikamDC"
  }

  metadata = <<METADATA
    {
        "foo": "bar2"
    }
METADATA
}
