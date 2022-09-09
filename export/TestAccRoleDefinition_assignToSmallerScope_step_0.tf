
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220909033849426603"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "c521b4e1-5c6b-4076-8c98-19561c914adf"
  name               = "acctestrd-220909033849426603"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
