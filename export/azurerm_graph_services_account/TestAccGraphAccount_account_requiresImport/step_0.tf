

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-230929064947053482"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap230929064947053482"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-230929064947053482"
  application_id      = "ARM_CLIENT_ID"
  resource_group_name = azurerm_resource_group.test.name
}
