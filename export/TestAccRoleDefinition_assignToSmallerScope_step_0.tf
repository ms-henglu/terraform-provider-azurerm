
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812014637241022"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "51614e02-8912-4081-bc99-56b3884b26a3"
  name               = "acctestrd-220812014637241022"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
