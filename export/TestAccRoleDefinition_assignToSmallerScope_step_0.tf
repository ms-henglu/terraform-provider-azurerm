
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610092324744371"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "1be2db56-c3f1-4b9a-be7f-5efe784425a8"
  name               = "acctestrd-220610092324744371"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
