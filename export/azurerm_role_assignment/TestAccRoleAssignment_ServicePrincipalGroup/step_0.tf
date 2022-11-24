
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221124181238151745"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "1caf6bc5-f635-4226-818a-aa7cf3bd72c7"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
