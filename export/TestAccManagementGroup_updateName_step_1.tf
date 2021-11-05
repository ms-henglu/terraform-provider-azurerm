
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211105040131960977"
  display_name = "accTestMG-211105040131960977"
}
