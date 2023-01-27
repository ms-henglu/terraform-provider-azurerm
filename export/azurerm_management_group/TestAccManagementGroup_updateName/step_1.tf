
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230127045720172705"
  display_name = "accTestMG-230127045720172705"
}
