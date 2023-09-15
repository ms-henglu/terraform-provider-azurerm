
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230915023735536502"
  display_name = "accTestMG-230915023735536502"
}
