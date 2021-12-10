
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-211210024315780236"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "30aad2ff-8661-46b1-bfee-2ab9ea838c26"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
