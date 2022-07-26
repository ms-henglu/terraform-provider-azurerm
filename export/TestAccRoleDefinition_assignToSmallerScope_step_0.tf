
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726001552987390"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "7b7ffd73-1547-4465-b421-49f5c673dd8e"
  name               = "acctestrd-220726001552987390"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
