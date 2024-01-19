
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test" {
  name                 = "73e0a829-f98c-4bb7-a546-e358aa9a91ce"
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Monitoring Reader"
  principal_id         = data.azurerm_client_config.test.object_id
  description          = "Monitoring Reader except "
  condition            = "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase 'foo_storage_container'"
  condition_version    = "1.0"
}
