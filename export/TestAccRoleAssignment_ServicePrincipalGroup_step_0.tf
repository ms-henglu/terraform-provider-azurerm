
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220726001552989863"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "52768a39-dd78-4a99-ad69-c96f64d17ce1"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
