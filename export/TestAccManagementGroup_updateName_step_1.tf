
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220726015020766650"
  display_name = "accTestMG-220726015020766650"
}
