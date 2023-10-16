
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-231016033638230819"
  location = "West Europe"
}

resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-231016033638230819"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_capacity_reservation" "test" {
  name                          = "acctest-ccr-231016033638230819"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.test.id

  sku {
    name     = "Standard_D2s_v3"
    capacity = 2
  }
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest231016033638230819"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_capacity_reservation_group.test.id
  principal_id         = azurerm_user_assigned_identity.test.principal_id
  role_definition_name = "Owner"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks231016033638230819"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks231016033638230819"
  default_node_pool {
    name                          = "default"
    node_count                    = 1
    vm_size                       = "Standard_D2s_v3"
    capacity_reservation_group_id = azurerm_capacity_reservation.test.capacity_reservation_group_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  depends_on = [
    azurerm_capacity_reservation.test,
    azurerm_role_assignment.test
  ]
}
