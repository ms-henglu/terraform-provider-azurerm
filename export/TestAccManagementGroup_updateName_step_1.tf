
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220527034407045624"
  display_name = "accTestMG-220527034407045624"
}
