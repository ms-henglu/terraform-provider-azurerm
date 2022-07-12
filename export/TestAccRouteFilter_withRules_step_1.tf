
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042617977023"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220712042617977023"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  rule {
    name        = "acctestrule220712042617977023"
    access      = "Allow"
    rule_type   = "Community"
    communities = ["12076:52005", "12076:52006"]
  }
}
