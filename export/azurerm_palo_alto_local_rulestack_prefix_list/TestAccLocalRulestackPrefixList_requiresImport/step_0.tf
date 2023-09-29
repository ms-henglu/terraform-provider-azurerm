
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-230929065452016833"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-230929065452016833"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}



resource "azurerm_palo_alto_local_rulestack_prefix_list" "test" {
  name         = "testacc-palr-230929065452016833"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id

  prefix_list = ["10.0.0.0/8", "172.16.0.0/16"]
}
