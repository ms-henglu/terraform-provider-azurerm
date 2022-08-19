
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220819164917641519"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "f99918f1-e41e-49be-83a8-1ccc435f3ecd"
  name               = "acctestrd-220819164917641519"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
