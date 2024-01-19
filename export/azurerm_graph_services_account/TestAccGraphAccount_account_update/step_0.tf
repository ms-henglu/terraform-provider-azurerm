

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-240119025106707706"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap240119025106707706"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-240119025106707706"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
