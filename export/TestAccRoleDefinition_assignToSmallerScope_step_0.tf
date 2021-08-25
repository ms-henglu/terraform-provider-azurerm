
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825025530429918"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "55be1ef0-7ea7-4045-9a14-c74b2b93674f"
  name               = "acctestrd-210825025530429918"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
