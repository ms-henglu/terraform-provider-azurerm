
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-221019060821688614"
  display_name = "accTestMG-221019060821688614"
}
