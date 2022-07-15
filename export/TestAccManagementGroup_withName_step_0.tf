
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220715004636225686"
  display_name = "accTestMG-220715004636225686"
}
