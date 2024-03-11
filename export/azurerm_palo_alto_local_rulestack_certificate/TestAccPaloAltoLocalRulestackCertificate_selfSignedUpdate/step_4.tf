
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-240311032830264901"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-240311032830264901"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack_certificate" "test" {
  name         = "testacc-palc-240311032830264901"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id
  self_signed  = true

  audit_comment = "Updated acceptance test audit comment - 240311032830264901"
  description   = "Updated acceptance test Desc - 240311032830264901"
}


