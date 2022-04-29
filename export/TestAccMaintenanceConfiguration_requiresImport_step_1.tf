

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-maint-220429065723932853"
  location = "West Europe"
}

resource "azurerm_maintenance_configuration" "test" {
  name                = "acctest-MC220429065723932853"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope               = "All"
  visibility          = "Custom"
}


resource "azurerm_maintenance_configuration" "import" {
  name                = azurerm_maintenance_configuration.test.name
  resource_group_name = azurerm_maintenance_configuration.test.resource_group_name
  location            = azurerm_maintenance_configuration.test.location
  scope               = azurerm_maintenance_configuration.test.scope
  visibility          = azurerm_maintenance_configuration.test.visibility
}
