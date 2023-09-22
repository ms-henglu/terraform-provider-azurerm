
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230922061448291691"
  display_name = "accTestMG-230922061448291691"
}
