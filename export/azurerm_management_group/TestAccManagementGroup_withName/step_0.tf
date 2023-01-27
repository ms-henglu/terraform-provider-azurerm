
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230127045720170038"
  display_name = "accTestMG-230127045720170038"
}
