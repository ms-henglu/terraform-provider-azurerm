


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061842625532"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice230922061842625532"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_account" "test" {
  name                = "accptg6e"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_search_shared_private_link_service" "test" {
  name               = "acctest230922061842625532"
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
