
				

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033638250669"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestAKC-231016033638250669"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks231016033638250669"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-231016033638250669"
  cluster_id     = azurerm_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"
}



resource "azurerm_storage_account" "test" {
  name                     = "sa231016033638250669"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231016033638250669"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-231016033638250669"
  cluster_id = azurerm_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id             = azurerm_storage_container.test.id
    account_key              = azurerm_storage_account.test.primary_access_key
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.test
  ]
}
