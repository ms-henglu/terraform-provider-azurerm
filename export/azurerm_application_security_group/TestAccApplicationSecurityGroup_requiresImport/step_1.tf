

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034430958063"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-231016034430958063"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_application_security_group" "import" {
  name                = azurerm_application_security_group.test.name
  location            = azurerm_application_security_group.test.location
  resource_group_name = azurerm_application_security_group.test.resource_group_name
}
