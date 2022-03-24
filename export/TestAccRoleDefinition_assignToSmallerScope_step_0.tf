
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324175940278121"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "9d27ed92-d414-4856-bf47-b623957d9be4"
  name               = "acctestrd-220324175940278121"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
