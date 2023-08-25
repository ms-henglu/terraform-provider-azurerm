
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825023946789547"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230825023946789547"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_group" "test" {
  name                = "acctestAMGroup-230825023946789547"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "Test Group"
}

resource "azurerm_api_management_user" "test" {
  user_id             = "acctestuser230825023946789547"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  first_name          = "Acceptance"
  last_name           = "Test"
  email               = "azure-acctest230825023946789547@example.com"
}

resource "azurerm_api_management_group_user" "test" {
  user_id             = azurerm_api_management_user.test.user_id
  group_name          = azurerm_api_management_group.test.name
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
}
