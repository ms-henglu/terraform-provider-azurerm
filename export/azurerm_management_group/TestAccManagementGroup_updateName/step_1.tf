
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230227175708019244"
  display_name = "accTestMG-230227175708019244"
}
