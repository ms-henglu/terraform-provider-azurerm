
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test" {
  name                 = "7136141b-7ba6-439d-b695-e1aea885d7ee"
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Monitoring Reader"
  principal_id         = data.azurerm_client_config.test.object_id
  description          = "Monitoring Reader except "
  condition            = "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase 'foo_storage_container'"
  condition_version    = "1.0"
}
