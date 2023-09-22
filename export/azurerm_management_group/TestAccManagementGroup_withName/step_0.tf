
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230922061448299399"
  display_name = "accTestMG-230922061448299399"
}
