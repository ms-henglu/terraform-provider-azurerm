



provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-230825025058135693"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-230825025058135693"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack_fqdn_list" "test" {
  name         = "testacc-pafqdn-230825025058135693"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id

  fully_qualified_domain_names = ["contoso.com", "test.example.com"]
}




resource "azurerm_palo_alto_local_rulestack_fqdn_list" "import" {
  name         = azurerm_palo_alto_local_rulestack_fqdn_list.test.name
  rulestack_id = azurerm_palo_alto_local_rulestack_fqdn_list.test.rulestack_id

  fully_qualified_domain_names = azurerm_palo_alto_local_rulestack_fqdn_list.test.fully_qualified_domain_names
}


