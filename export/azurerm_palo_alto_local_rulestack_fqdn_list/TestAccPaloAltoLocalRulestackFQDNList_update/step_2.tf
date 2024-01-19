
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-240119025601461853"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-240119025601461853"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack_fqdn_list" "test" {
  name         = "testacc-pafqdn-240119025601461853"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id

  fully_qualified_domain_names = ["contoso.com", "test.example.com", "anothertest.example.com"]

  audit_comment = "Acc Test Audit Comment - 240119025601461853"
  description   = "Acc Test Description - 240119025601461853"
}


