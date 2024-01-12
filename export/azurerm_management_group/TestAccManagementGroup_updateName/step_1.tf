
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-240112224812687956"
  display_name = "accTestMG-240112224812687956"
}
