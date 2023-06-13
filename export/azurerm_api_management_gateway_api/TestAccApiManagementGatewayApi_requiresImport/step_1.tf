

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071241517859"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230613071241517859"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_gateway" "test" {
  name              = "acctestAMGateway-230613071241517859"
  api_management_id = azurerm_api_management.test.id
  description       = "this is a test gateway"

  location_data {
    name     = "old world"
    city     = "test city"
    district = "test district"
    region   = "test region"
  }
}

resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-230613071241517859"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
}

resource "azurerm_api_management_gateway_api" "test" {
  gateway_id = azurerm_api_management_gateway.test.id
  api_id     = azurerm_api_management_api.test.id
}


resource "azurerm_api_management_gateway_api" "import" {
  gateway_id = azurerm_api_management_gateway_api.test.gateway_id
  api_id     = azurerm_api_management_gateway_api.test.api_id
}
