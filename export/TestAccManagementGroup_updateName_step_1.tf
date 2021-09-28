
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210928055638759864"
  display_name = "accTestMG-210928055638759864"
}
