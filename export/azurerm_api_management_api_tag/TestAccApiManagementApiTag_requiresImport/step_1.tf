



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064257480646"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230929064257480646"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-230929064257480646"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
}

resource "azurerm_api_management_tag" "test" {
  api_management_id = azurerm_api_management.test.id
  name              = "acctest-Tag-230929064257480646"
}

resource "azurerm_api_management_api_tag" "test" {
  api_id = azurerm_api_management_api.test.id
  name   = "acctest-Tag-230929064257480646"
}

resource "azurerm_api_management_api_tag" "import" {
  api_id = azurerm_api_management_api.test.id
  name   = azurerm_api_management_api_tag.test.name
}
