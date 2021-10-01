
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211001053933261781"
  display_name = "accTestMG-211001053933261781"
}
