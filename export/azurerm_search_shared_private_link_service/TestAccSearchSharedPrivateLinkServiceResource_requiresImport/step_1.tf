


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034529002213"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice221021034529002213"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_account" "test" {
  name                = "acc0vmhg"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_search_shared_private_link_service" "test" {
  name               = "acctest221021034529002213"
  search_service_id  = azurerm_search_service.test.id
  subresource_name   = "blob"
  target_resource_id = azurerm_storage_account.test.id
  request_message    = "please approve"
}


resource "azurerm_search_shared_private_link_service" "import" {
  name               = azurerm_search_shared_private_link_service.test.name
  search_service_id  = azurerm_search_shared_private_link_service.test.search_service_id
  subresource_name   = azurerm_search_shared_private_link_service.test.subresource_name
  target_resource_id = azurerm_search_shared_private_link_service.test.target_resource_id
  request_message    = azurerm_search_shared_private_link_service.test.request_message
}
