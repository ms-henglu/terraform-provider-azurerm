

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-210825044817333150"
  location = "West Europe"
}


resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-210825044817333150"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
