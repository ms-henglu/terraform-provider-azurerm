

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-221111013552028576"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-221111013552028576"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    Env = "Test"
  }
}
