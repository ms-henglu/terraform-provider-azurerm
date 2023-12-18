

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-231218071836890583"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap231218071836890583"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-231218071836890583"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
