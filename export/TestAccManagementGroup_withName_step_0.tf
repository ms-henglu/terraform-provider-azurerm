
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220603005040522646"
  display_name = "accTestMG-220603005040522646"
}
