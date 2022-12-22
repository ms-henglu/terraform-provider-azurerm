


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-221222034908757104"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-221222034908757104"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_partner" "test" {
  name                     = "acctest-iap-221222034908757104"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name

  business_identity {
    qualifier = "DUNS"
    value     = "FabrikamNY"
  }
}


resource "azurerm_logic_app_integration_account_partner" "import" {
  name                     = azurerm_logic_app_integration_account_partner.test.name
  resource_group_name      = azurerm_logic_app_integration_account_partner.test.resource_group_name
  integration_account_name = azurerm_logic_app_integration_account_partner.test.integration_account_name

  business_identity {
    qualifier = "DUNS"
    value     = "FabrikamNY"
  }
}
