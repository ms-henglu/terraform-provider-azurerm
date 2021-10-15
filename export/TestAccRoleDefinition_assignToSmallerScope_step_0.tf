
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015013913036590"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "b11e041f-654c-4c5a-aae2-99b69240bd6a"
  name               = "acctestrd-211015013913036590"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
