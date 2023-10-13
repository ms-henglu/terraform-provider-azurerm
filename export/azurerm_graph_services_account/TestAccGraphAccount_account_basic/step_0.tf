

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-231013043529305060"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap231013043529305060"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-231013043529305060"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
