

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013071501507511"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-211013071501507511"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}


resource "azurerm_api_management_user" "test" {
  user_id             = "acctestuser211013071501507511"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  first_name          = "Acceptance"
  last_name           = "Test"
  email               = "azure-acctest211013071501507511@example.com"
  state               = "active"
  confirmation        = "signup"
  note                = "Used for testing in dimension C-137."
}
