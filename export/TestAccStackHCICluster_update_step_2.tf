

provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "current" {}

resource "azuread_application" "test" {
  name = "acctestspa-211013071545284776"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-hci-211013071545284776"
  location = "West Europe"
}


resource "azurerm_stack_hci_cluster" "test" {
  name                = "acctest-StackHCICluster-211013071545284776"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  client_id           = azuread_application.test.application_id
  tenant_id           = data.azurerm_client_config.current.tenant_id

  tags = {
    ENv = "Test2"
  }
}
