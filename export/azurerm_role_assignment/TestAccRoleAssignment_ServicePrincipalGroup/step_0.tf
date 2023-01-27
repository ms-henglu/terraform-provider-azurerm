
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230127045005241732"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "2642875b-699a-4919-a34f-0818a7f92d5d"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
