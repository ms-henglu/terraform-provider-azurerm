


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-221222034908752765"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-221222034908752765"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_partner" "host" {
  name                     = "acctest-hostpartner-221222034908752765"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name

  business_identity {
    qualifier = "AS2Identity"
    value     = "FabrikamNY"
  }
}

resource "azurerm_logic_app_integration_account_partner" "guest" {
  name                     = "acctest-guestpartner-221222034908752765"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name

  business_identity {
    qualifier = "AS2Identity"
    value     = "FabrikamDC"
  }
}

resource "azurerm_logic_app_integration_account_agreement" "test" {
  name                     = "acctest-agreement-221222034908752765"
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
}


resource "azurerm_logic_app_integration_account_agreement" "import" {
  name                     = azurerm_logic_app_integration_account_agreement.test.name
  resource_group_name      = azurerm_logic_app_integration_account_agreement.test.resource_group_name
  integration_account_name = azurerm_logic_app_integration_account_agreement.test.integration_account_name
  agreement_type           = azurerm_logic_app_integration_account_agreement.test.agreement_type
  host_partner_name        = azurerm_logic_app_integration_account_agreement.test.host_partner_name
  guest_partner_name       = azurerm_logic_app_integration_account_agreement.test.guest_partner_name
  content                  = azurerm_logic_app_integration_account_agreement.test.content

  host_identity {
    qualifier = "AS2Identity"
    value     = "FabrikamNY"
  }

  guest_identity {
    qualifier = "AS2Identity"
    value     = "FabrikamDC"
  }
}
