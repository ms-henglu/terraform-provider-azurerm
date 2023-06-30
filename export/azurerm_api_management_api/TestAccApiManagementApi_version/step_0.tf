

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032559662961"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230630032559662961"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_api_version_set" "test" {
  name                = "acctestAMAVS-230630032559662961"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "Butter Parser"
  versioning_scheme   = "Segment"
}

resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-230630032559662961"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
  version             = "v1"
  version_set_id      = azurerm_api_management_api_version_set.test.id
}
