
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526084616519668"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "b0c80308-a705-47ba-85ce-9422cb8b28af"
  name               = "acctestrd-230526084616519668"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
