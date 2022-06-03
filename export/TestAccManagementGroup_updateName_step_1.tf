
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220603005040521322"
  display_name = "accTestMG-220603005040521322"
}
