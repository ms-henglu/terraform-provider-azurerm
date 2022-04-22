
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220422012057741648"
  display_name = "accTestMG-220422012057741648"
}
