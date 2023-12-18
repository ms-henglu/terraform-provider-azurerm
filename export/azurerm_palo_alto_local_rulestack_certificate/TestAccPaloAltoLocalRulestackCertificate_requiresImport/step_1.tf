



provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-231218072332081131"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-231218072332081131"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack_certificate" "test" {
  name         = "testacc-palc-231218072332081131"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id
  self_signed  = true
}




resource "azurerm_palo_alto_local_rulestack_certificate" "import" {
  name         = azurerm_palo_alto_local_rulestack_certificate.test.name
  rulestack_id = azurerm_palo_alto_local_rulestack_certificate.test.rulestack_id
  self_signed  = azurerm_palo_alto_local_rulestack_certificate.test.self_signed
}


