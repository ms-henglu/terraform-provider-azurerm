
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-231016034505609764"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-231016034505609764"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}



resource "azurerm_palo_alto_local_rulestack_prefix_list" "test" {
  name         = "testacc-palr-231016034505609764"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id

  prefix_list = ["10.0.0.0/8", "172.16.0.0/16"]

  audit_comment = "Updated acceptance test audit comment - 231016034505609764"
  description   = "Updated acceptance test Desc - 231016034505609764"

}
