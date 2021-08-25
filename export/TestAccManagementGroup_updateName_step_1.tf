
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-210825041022284004"
  display_name = "accTestMG-210825041022284004"
}
