
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221124181942390152"
  display_name = "accTestMG-221124181942390152"
}
