

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-231016034002603933"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap231016034002603933"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-231016034002603933"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
