

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-231013043529308312"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap231013043529308312"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-231013043529308312"
  resource_group_name = azurerm_resource_group.test.name
  application_id      = "ARM_CLIENT_ID"
  tags = {
    environment = "terraform-acctests"
    some_key    = "some-value"
  }
}
