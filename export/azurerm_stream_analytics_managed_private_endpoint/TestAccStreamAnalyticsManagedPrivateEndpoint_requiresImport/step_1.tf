


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231557417702"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "accteststorageacc0zv0o"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_stream_analytics_cluster" "test" {
  name                = "acctestcluster-221117231557417702"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  streaming_capacity  = 36
}


resource "azurerm_stream_analytics_managed_private_endpoint" "test" {
  name                          = "acctestprivate_endpoint-221117231557417702"
  resource_group_name           = azurerm_resource_group.test.name
  stream_analytics_cluster_name = azurerm_stream_analytics_cluster.test.name
  target_resource_id            = azurerm_storage_account.test.id
  subresource_name              = "blob"
}


resource "azurerm_stream_analytics_managed_private_endpoint" "import" {
  name                          = azurerm_stream_analytics_managed_private_endpoint.test.name
  resource_group_name           = azurerm_stream_analytics_managed_private_endpoint.test.resource_group_name
  stream_analytics_cluster_name = azurerm_stream_analytics_managed_private_endpoint.test.stream_analytics_cluster_name
  target_resource_id            = azurerm_stream_analytics_managed_private_endpoint.test.target_resource_id
  subresource_name              = azurerm_stream_analytics_managed_private_endpoint.test.subresource_name
}
