
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128082113121484"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "43cf2b5a-9625-4fad-bf03-4d14e1373c6c"
  name               = "acctestrd-220128082113121484"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
