
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230316221855948050"
  display_name = "accTestMG-230316221855948050"
}
