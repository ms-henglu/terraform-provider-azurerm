
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220520054243905673"
  display_name = "accTestMG-220520054243905673"
}
