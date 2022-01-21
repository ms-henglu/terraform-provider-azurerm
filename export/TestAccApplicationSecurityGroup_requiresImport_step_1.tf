

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044824841663"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-220121044824841663"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_application_security_group" "import" {
  name                = azurerm_application_security_group.test.name
  location            = azurerm_application_security_group.test.location
  resource_group_name = azurerm_application_security_group.test.resource_group_name
}
