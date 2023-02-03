
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230203063711751522"
  display_name = "accTestMG-230203063711751522"
}
