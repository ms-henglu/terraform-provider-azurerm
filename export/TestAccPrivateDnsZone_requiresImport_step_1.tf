

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065923075373"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220429065923075373.com"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_private_dns_zone" "import" {
  name                = azurerm_private_dns_zone.test.name
  resource_group_name = azurerm_private_dns_zone.test.resource_group_name
}
