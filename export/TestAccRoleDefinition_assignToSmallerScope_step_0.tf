
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203013434118939"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "65bf52a3-5460-40c8-ae60-6a4f00d3ae8f"
  name               = "acctestrd-211203013434118939"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
