


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-240105061034206733"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-240105061034206733"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_partner" "test" {
  name                     = "acctest-iap-240105061034206733"
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
