

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-240311031945104860"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest240311031945104860"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-240311031945104860"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }
}
