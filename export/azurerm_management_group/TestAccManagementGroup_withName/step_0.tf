
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230324052358378637"
  display_name = "accTestMG-230324052358378637"
}
