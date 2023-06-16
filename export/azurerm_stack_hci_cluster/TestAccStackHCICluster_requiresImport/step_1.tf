


provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "current" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230616074328742823"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-hci-230616074328742823"
  location = "West Europe"
}


resource "azurerm_stack_hci_cluster" "test" {
  name                = "acctest-StackHCICluster-230616074328742823"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  client_id           = azuread_application.test.application_id
  tenant_id           = data.azurerm_client_config.current.tenant_id
}


resource "azurerm_stack_hci_cluster" "import" {
  name                = azurerm_stack_hci_cluster.test.name
  resource_group_name = azurerm_stack_hci_cluster.test.resource_group_name
  location            = azurerm_stack_hci_cluster.test.location
  client_id           = azurerm_stack_hci_cluster.test.client_id
  tenant_id           = azurerm_stack_hci_cluster.test.tenant_id
}
