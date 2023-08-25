
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024038298550"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "668de2df-51f3-4ae1-b8de-712926651747"
  name               = "acctestrd-230825024038298550"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
