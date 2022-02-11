
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220211043909435536"
  display_name = "accTestMG-220211043909435536"
}
