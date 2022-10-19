
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221019054610419756"
  display_name = "accTestMG-221019054610419756"
}
