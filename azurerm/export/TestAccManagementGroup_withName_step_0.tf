
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220627130020284627"
  display_name = "accTestMG-220627130020284627"
}
