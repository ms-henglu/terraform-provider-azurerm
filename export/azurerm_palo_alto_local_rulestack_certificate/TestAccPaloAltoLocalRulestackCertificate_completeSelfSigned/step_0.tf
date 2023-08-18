
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-230818024555092402"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-230818024555092402"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack_certificate" "test" {
  name         = "testacc-palc-230818024555092402"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id
  self_signed  = true

  audit_comment = "Acceptance test audit comment - 230818024555092402"
  description   = "Acceptance test Desc - 230818024555092402"
}


