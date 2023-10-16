
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-231016034505608692"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-231016034505608692"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack_certificate" "test" {
  name         = "testacc-palc-231016034505608692"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id
  self_signed  = true
}


