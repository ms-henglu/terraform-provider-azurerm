
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220627122826429741"
  display_name = "accTestMG-220627122826429741"
}
