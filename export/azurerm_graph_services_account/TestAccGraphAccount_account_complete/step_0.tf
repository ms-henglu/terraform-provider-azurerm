

provider "azuread" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-graph-230825024616623334"
  location = "West Europe"
}

resource "azuread_application" "test" {
  display_name = "acctestsap230825024616623334"
}


resource "azurerm_graph_services_account" "test" {
  name                = "acctesta-230825024616623334"
  resource_group_name = azurerm_resource_group.test.name
  application_id      = "ARM_CLIENT_ID"
  tags = {
    environment = "terraform-acctests"
    some_key    = "some-value"
  }
}
