

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014533306955"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestd4xpt"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_user_assigned_identity" "import" {
  name                = azurerm_user_assigned_identity.test.name
  resource_group_name = azurerm_user_assigned_identity.test.resource_group_name
  location            = azurerm_user_assigned_identity.test.location
}
