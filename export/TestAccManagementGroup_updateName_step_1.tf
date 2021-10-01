
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211001053933267024"
  display_name = "accTestMG-211001053933267024"
}
