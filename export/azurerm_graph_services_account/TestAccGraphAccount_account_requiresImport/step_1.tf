


provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-230818024106427366"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap230818024106427366"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-230818024106427366"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_graph_services_account" "import" {
  application_id      = azurerm_graph_services_account.test.application_id
  name                = azurerm_graph_services_account.test.name
  resource_group_name = azurerm_graph_services_account.test.resource_group_name
}
