

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324051554816142"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230324051554816142"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_group" "test" {
  name                = "acctestAMGroup-230324051554816142"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "Test Group"
}

resource "azurerm_api_management_user" "test" {
  user_id             = "acctestuser230324051554816142"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  first_name          = "Acceptance"
  last_name           = "Test"
  email               = "azure-acctest230324051554816142@example.com"
}

resource "azurerm_api_management_group_user" "test" {
  user_id             = azurerm_api_management_user.test.user_id
  group_name          = azurerm_api_management_group.test.name
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_api_management_group_user" "import" {
  user_id             = azurerm_api_management_group_user.test.user_id
  group_name          = azurerm_api_management_group_user.test.group_name
  api_management_name = azurerm_api_management_group_user.test.api_management_name
  resource_group_name = azurerm_api_management_group_user.test.resource_group_name
}
