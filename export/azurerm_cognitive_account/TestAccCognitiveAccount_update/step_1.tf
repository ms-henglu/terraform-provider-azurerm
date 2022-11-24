
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-221124181329831824"
  location = "West Europe"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-221124181329831824"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Face"
  sku_name            = "S0"

  fqdns                         = ["foo.com", "bar.com"]
  public_network_access_enabled = false
  local_auth_enabled            = false
  outbound_network_access_restricted = true

  tags = {
    Acceptance = "Test"
  }
}
