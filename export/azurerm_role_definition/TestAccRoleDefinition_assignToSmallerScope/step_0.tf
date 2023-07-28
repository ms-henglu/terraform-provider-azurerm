
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031752026049"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "1856e7b6-772b-45c6-bc58-0703bb52866b"
  name               = "acctestrd-230728031752026049"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
