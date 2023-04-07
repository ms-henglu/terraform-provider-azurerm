
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230407023712275585"
  display_name = "accTestMG-230407023712275585"
}
