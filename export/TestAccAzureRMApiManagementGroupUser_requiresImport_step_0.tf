
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013071501471378"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-211013071501471378"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_group" "test" {
  name                = "acctestAMGroup-211013071501471378"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "Test Group"
}

resource "azurerm_api_management_user" "test" {
  user_id             = "acctestuser211013071501471378"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  first_name          = "Acceptance"
  last_name           = "Test"
  email               = "azure-acctest211013071501471378@example.com"
}

resource "azurerm_api_management_group_user" "test" {
  user_id             = azurerm_api_management_user.test.user_id
  group_name          = azurerm_api_management_group.test.name
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
}
