

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-211022002009991648"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-211022002009991648"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
