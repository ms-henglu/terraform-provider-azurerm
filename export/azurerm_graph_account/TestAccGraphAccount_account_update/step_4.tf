

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-230721011725288420"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap230721011725288420"
}


resource "azurerm_graph_account" "test" {
  name                = "acctesta-230721011725288420"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
