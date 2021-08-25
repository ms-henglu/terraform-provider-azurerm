
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825031423438177"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "514065ae-168b-4375-9910-6c9f364049a3"
  name               = "acctestrd-210825031423438177"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
