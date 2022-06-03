

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220603004857905943"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-220603004857905943"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
