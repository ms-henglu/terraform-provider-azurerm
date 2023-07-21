
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014459550934"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "1e254510-f2ab-4307-bbe7-ef94d3bca57a"
  name               = "acctestrd-230721014459550934"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
