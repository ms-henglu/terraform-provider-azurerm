

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230915023656656717"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-230915023656656717"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_partner" "host" {
  name                     = "acctest-hostpartner-230915023656656717"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name

  business_identity {
    qualifier = "AS2Identity"
    value     = "FabrikamNY"
  }
}

resource "azurerm_logic_app_integration_account_partner" "guest" {
  name                     = "acctest-guestpartner-230915023656656717"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name

  business_identity {
    qualifier = "AS2Identity"
    value     = "FabrikamDC"
  }
}

resource "azurerm_logic_app_integration_account_agreement" "test" {
  name                     = "acctest-agreement-230915023656656717"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  agreement_type           = "AS2"
  host_partner_name        = azurerm_logic_app_integration_account_partner.host.name
  guest_partner_name       = azurerm_logic_app_integration_account_partner.guest.name
  content                  = file("testdata/integration_account_agreement_content_as2.json")

  host_identity {
    qualifier = "AS2Identity"
    value     = "FabrikamNY"
  }

  guest_identity {
    qualifier = "AS2Identity"
    value     = "FabrikamDC"
  }

  metadata = {
    foo = "bar"
  }
}
