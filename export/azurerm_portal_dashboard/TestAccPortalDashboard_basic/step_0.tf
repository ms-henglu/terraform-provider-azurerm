
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061726534119"
  location = "West Europe"
}

resource "azurerm_portal_dashboard" "test" {
  name                = "my-test-dashboard"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  dashboard_properties = <<DASH
{
  "lenses": {}
}
DASH
}
