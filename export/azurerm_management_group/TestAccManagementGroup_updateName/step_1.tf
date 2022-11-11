
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221111013845592168"
  display_name = "accTestMG-221111013845592168"
}
