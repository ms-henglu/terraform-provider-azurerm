

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063401626124"
  location = "West Europe"
}

resource "azurerm_bot_service_azure_bot" "test" {
  name                = "acctestdf240105063401626124"
  resource_group_name = azurerm_resource_group.test.name
  location            = "global"
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id

  tags = {
    environment = "test"
  }
}


resource "azurerm_bot_service_azure_bot" "import" {
  name                = azurerm_bot_service_azure_bot.test.name
  resource_group_name = azurerm_bot_service_azure_bot.test.resource_group_name
  location            = azurerm_bot_service_azure_bot.test.location
  sku                 = azurerm_bot_service_azure_bot.test.sku
  microsoft_app_id    = azurerm_bot_service_azure_bot.test.microsoft_app_id
}
