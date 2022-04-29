

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065809597753"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestanr1y"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_user_assigned_identity" "import" {
  name                = azurerm_user_assigned_identity.test.name
  resource_group_name = azurerm_user_assigned_identity.test.resource_group_name
  location            = azurerm_user_assigned_identity.test.location
}
