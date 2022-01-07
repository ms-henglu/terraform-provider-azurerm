
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "6b6dd81d-3b7a-4c7d-baec-e5d72a3d28a7"
  name               = "acctestrd-220107063642729751"
  scope              = data.azurerm_subscription.primary.id
  description        = "Acceptance Test Role Definition"

  permissions {
    actions          = ["*"]
    data_actions     = ["Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"]
    not_actions      = ["Microsoft.Authorization/*/read"]
    not_data_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}
