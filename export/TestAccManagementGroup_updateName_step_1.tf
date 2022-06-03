
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-220603022325296509"
  display_name = "accTestMG-220603022325296509"
}
