

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034539858896"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone231016034539858896.com"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_private_dns_zone" "import" {
  name                = azurerm_private_dns_zone.test.name
  resource_group_name = azurerm_private_dns_zone.test.resource_group_name
}
