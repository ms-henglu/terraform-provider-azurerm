
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119050518085654"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "435281d3-8300-4164-8bd7-0f1d72ec2685"
  name               = "acctestrd-211119050518085654"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
