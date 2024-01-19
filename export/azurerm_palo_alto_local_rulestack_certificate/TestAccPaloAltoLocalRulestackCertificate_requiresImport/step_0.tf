
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-240119025601468468"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-240119025601468468"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack_certificate" "test" {
  name         = "testacc-palc-240119025601468468"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id
  self_signed  = true
}


