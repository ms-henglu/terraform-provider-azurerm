
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217034918543356"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "4814c93c-d2e0-45fb-9392-cb6284c87839"
  name               = "acctestrd-211217034918543356"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
