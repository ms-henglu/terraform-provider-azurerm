

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028171659674911"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221028171659674911"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}


resource "azurerm_api_management_user" "test" {
  user_id             = "acctestuser221028171659674911"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  first_name          = "Acceptance Updated"
  last_name           = "Test Updated"
  email               = "azure-acctest221028171659674911@example.com"
  state               = "blocked"
}
