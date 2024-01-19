


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024407469401"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240119024407469401"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}


resource "azurerm_api_management_user" "test" {
  user_id             = "acctestuser240119024407469401"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  first_name          = "Acceptance"
  last_name           = "Test"
  email               = "azure-acctest240119024407469401@example.com"
}


resource "azurerm_api_management_user" "import" {
  user_id             = azurerm_api_management_user.test.user_id
  api_management_name = azurerm_api_management_user.test.api_management_name
  resource_group_name = azurerm_api_management_user.test.resource_group_name
  first_name          = azurerm_api_management_user.test.first_name
  last_name           = azurerm_api_management_user.test.last_name
  email               = azurerm_api_management_user.test.email
  state               = azurerm_api_management_user.test.state
}
