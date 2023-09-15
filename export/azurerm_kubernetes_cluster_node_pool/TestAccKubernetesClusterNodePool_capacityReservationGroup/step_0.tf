
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230915023140761234"
  location = "West Europe"
}

resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-230915023140761234"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_capacity_reservation" "test" {
  name                          = "acctest-ccr-230915023140761234"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.test.id

  sku {
    name     = "Standard_D2s_v3"
    capacity = 2
  }
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest230915023140761234"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_capacity_reservation_group.test.id
  principal_id         = azurerm_user_assigned_identity.test.principal_id
  role_definition_name = "Owner"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230915023140761234"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230915023140761234"
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
resource "azurerm_kubernetes_cluster_node_pool" "test" {
  name                          = "internal"
  kubernetes_cluster_id         = azurerm_kubernetes_cluster.test.id
  vm_size                       = "Standard_D2s_v3"
  node_count                    = 1
  capacity_reservation_group_id = azurerm_capacity_reservation.test.capacity_reservation_group_id
}
