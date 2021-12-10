
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211210024801527374"
  display_name = "accTestMG-211210024801527374"
}
