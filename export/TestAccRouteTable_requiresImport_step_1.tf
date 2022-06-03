

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603005139100212"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220603005139100212"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_route_table" "import" {
  name                = azurerm_route_table.test.name
  location            = azurerm_route_table.test.location
  resource_group_name = azurerm_route_table.test.resource_group_name
}
