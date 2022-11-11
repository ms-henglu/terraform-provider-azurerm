

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013031414533"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221111013031414533"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}


resource "azurerm_api_management_user" "test" {
  user_id             = "acctestuser221111013031414533"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  first_name          = "Acceptance"
  last_name           = "Test User"
  email               = "azure-acctest221111013031414533@example.com"
  state               = "blocked"
  confirmation        = "invite"
}
