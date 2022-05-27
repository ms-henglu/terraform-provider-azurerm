
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034514220367"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220527034514220367"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  rule {
    name        = "acctestrule220527034514220367"
    access      = "Allow"
    rule_type   = "Community"
    communities = ["12076:53005", "12076:53006"]
  }
}
