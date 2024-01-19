
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240119022405819427"
  display_name = "accTestMG-240119022405819427"
}
