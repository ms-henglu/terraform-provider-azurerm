
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181238159934"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "cc643dc8-cb24-4248-9ae4-534076175d71"
  name               = "acctestrd-221124181238159934"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
