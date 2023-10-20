

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-231020041139831413"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap231020041139831413"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-231020041139831413"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
