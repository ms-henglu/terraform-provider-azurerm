

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-230825024616625557"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap230825024616625557"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-230825024616625557"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
