
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220422012057742276"
  display_name = "accTestMG-220422012057742276"
}
