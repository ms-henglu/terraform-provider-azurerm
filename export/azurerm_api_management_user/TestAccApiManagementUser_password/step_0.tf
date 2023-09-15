

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022812176414"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230915022812176414"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}


resource "azurerm_api_management_user" "test" {
  user_id             = "acctestuser230915022812176414"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  first_name          = "Acceptance"
  last_name           = "Test"
  email               = "azure-acctest230915022812176414@example.com"
  state               = "active"
  password            = "3991bb15-282d-4b9b-9de3-3d5fc89eb530"
}
