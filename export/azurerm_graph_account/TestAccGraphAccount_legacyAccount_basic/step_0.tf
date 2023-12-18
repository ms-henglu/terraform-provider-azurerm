

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-231218071836894316"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap231218071836894316"
}


resource "azurerm_graph_account" "test" {
  name                = "acctesta-231218071836894316"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
