
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230313021511761971"
  display_name = "accTestMG-230313021511761971"
}
