
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014003176278"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf221111014003176278"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  rule {
    name        = "acctestrule221111014003176278"
    access      = "Allow"
    rule_type   = "Community"
    communities = ["12076:53005", "12076:53006"]
  }
}
