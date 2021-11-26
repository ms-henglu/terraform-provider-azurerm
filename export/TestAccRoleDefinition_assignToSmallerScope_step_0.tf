
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211126030911783235"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "447cbc00-f5ef-42ef-96c2-bae7d42bd2cb"
  name               = "acctestrd-211126030911783235"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
