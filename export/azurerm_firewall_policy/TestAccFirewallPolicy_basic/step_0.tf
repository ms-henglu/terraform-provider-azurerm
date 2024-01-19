

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-240119025046817370"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-240119025046817370"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    Env = "Test"
  }
}
