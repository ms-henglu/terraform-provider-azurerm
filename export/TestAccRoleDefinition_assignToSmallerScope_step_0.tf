
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220905045429465355"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "5390a4b8-fe08-41cc-a7b2-696abb570923"
  name               = "acctestrd-220905045429465355"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
