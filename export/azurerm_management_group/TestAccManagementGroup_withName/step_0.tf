
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-230818024340598624"
  display_name = "accTestMG-230818024340598624"
}
