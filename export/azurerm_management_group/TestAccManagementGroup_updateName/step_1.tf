
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221019060821686684"
  display_name = "accTestMG-221019060821686684"
}
