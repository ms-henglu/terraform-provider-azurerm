
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221021031442259517"
  display_name = "accTestMG-221021031442259517"
}
