
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044221418312"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "af5d1235-c30d-4baa-8bf0-5e224df00f49"
  name               = "acctestrd-220121044221418312"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
