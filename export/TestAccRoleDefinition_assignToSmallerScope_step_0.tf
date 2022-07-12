
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712041944530079"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "b077654c-ed57-434f-84ac-a329758e3cf7"
  name               = "acctestrd-220712041944530079"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
