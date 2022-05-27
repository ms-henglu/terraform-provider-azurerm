

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527033759573884"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220527033759573884"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}


resource "azurerm_api_management_user" "test" {
  user_id             = "acctestuser220527033759573884"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  first_name          = "Acceptance"
  last_name           = "Test"
  email               = "azure-acctest220527033759573884@example.com"
  state               = "active"
  confirmation        = "signup"
  note                = "Used for testing in dimension C-137."
}
