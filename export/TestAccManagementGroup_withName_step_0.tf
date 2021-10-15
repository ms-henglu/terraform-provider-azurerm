
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211015014830814264"
  display_name = "accTestMG-211015014830814264"
}
