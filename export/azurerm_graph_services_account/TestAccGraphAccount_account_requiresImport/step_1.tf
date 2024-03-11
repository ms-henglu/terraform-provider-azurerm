


provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-240311032158441304"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap240311032158441304"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-240311032158441304"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_graph_services_account" "import" {
  application_id      = azurerm_graph_services_account.test.application_id
  name                = azurerm_graph_services_account.test.name
  resource_group_name = azurerm_graph_services_account.test.resource_group_name
}
