
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220627131446770046"
  display_name = "accTestMG-220627131446770046"
}
