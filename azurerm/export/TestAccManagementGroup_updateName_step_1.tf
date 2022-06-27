
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220627134725995527"
  display_name = "accTestMG-220627134725995527"
}
