
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "c35ef25a-1f48-42ba-9774-eab43a3b675f"
  name               = "acctestrd-220527033831534026"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }
}
