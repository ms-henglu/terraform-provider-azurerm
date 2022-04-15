

provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "current" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-220415030157036538"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-hci-220415030157036538"
  location = "West Europe"
}


resource "azurerm_stack_hci_cluster" "test" {
  name                = "acctest-StackHCICluster-220415030157036538"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  client_id           = azuread_application.test.application_id
  tenant_id           = data.azurerm_client_config.current.tenant_id

  tags = {
    ENV = "Test"
  }
}
