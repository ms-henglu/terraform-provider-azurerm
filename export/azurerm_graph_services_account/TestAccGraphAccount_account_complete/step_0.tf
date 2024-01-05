

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-240105060842661882"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap240105060842661882"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-240105060842661882"
  resource_group_name = azurerm_resource_group.test.name
  application_id      = "ARM_CLIENT_ID"
  tags = {
    environment = "terraform-acctests"
    some_key    = "some-value"
  }
}
