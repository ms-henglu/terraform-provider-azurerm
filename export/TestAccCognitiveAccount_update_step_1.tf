
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-210825042637317721"
  location = "West Europe"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-210825042637317721"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Face"
  sku_name            = "S0"

  fqdns                             = ["foo.com", "bar.com"]
  public_network_access_enabled     = false
  outbound_network_access_restrited = true
  local_auth_enabled                = false

  tags = {
    Acceptance = "Test"
  }
}
