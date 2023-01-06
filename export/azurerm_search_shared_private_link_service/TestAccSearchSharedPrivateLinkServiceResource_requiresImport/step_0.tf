

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031909858714"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice230106031909858714"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_account" "test" {
  name                = "accxjmnd"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_search_shared_private_link_service" "test" {
  name               = "acctest230106031909858714"
  search_service_id  = azurerm_search_service.test.id
  subresource_name   = "blob"
  target_resource_id = azurerm_storage_account.test.id
  request_message    = "please approve"
}
