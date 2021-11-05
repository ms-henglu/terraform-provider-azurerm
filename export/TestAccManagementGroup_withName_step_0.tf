
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211105040131965446"
  display_name = "accTestMG-211105040131965446"
}
