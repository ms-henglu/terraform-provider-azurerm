
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-230825025058130596"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-230825025058130596"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack_certificate" "test" {
  name         = "testacc-palc-230825025058130596"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id
  self_signed  = true

  audit_comment = "Updated acceptance test audit comment - 230825025058130596"
  description   = "Updated acceptance test Desc - 230825025058130596"
}


