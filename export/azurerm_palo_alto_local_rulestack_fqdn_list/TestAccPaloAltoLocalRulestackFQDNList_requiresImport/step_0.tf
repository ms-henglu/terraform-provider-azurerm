
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-231016034505607380"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-231016034505607380"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack_fqdn_list" "test" {
  name         = "testacc-pafqdn-231016034505607380"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id

  fully_qualified_domain_names = ["contoso.com", "test.example.com"]
}


