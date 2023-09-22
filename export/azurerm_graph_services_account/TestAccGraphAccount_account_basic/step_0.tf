

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-230922061207715516"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap230922061207715516"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-230922061207715516"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
