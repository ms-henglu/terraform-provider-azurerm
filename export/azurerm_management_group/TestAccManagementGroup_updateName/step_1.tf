
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230922054442662244"
  display_name = "accTestMG-230922054442662244"
}
