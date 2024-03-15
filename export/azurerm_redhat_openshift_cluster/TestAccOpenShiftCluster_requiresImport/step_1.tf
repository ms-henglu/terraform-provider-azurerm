
  

provider "azurerm" {
  skip_provider_registration = true
  features {
    key_vault {
      recover_soft_deleted_key_vaults    = false
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

provider "azuread" {}

data "azurerm_client_config" "test" {}

data "azuread_client_config" "test" {}

resource "azuread_application" "test" {
  display_name = "acctest-aro-240315123909744948"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azuread_service_principal_password" "test" {
  service_principal_id = azuread_service_principal.test.object_id
}

data "azuread_service_principal" "redhatopenshift" {
  // This is the Azure Red Hat OpenShift RP service principal id, do NOT delete it
  application_id = "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875"
}

resource "azurerm_role_assignment" "role_network1" {
  scope                = azurerm_virtual_network.test.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.test.object_id
}

resource "azurerm_role_assignment" "role_network2" {
  scope                = azurerm_virtual_network.test.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.redhatopenshift.object_id
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aro-240315123909744948"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet240315123909744948"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "main_subnet" {
  name                 = "main-subnet-240315123909744948"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/23"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "worker_subnet" {
  name                 = "worker-subnet-240315123909744948"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/23"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
}
 

resource "azurerm_redhat_openshift_cluster" "test" {
  name                = "acctestaro240315123909744948"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  cluster_profile {
    domain  = "aro-kn9ow.com"
    version = "4.13.23"
  }

  network_profile {
    pod_cidr     = "10.128.0.0/14"
    service_cidr = "172.30.0.0/16"
  }

  main_profile {
    vm_size   = "Standard_D8s_v3"
    subnet_id = azurerm_subnet.main_subnet.id
  }

  api_server_profile {
    visibility = "Public"
  }

  ingress_profile {
    visibility = "Public"
  }

  worker_profile {
    vm_size      = "Standard_D4s_v3"
    disk_size_gb = 128
    node_count   = 3
    subnet_id    = azurerm_subnet.worker_subnet.id
  }

  service_principal {
    client_id     = azuread_application.test.application_id
    client_secret = azuread_service_principal_password.test.value
  }

  depends_on = [
    "azurerm_role_assignment.role_network1",
    "azurerm_role_assignment.role_network2",
  ]
}
  

resource "azurerm_redhat_openshift_cluster" "import" {
  name                = azurerm_redhat_openshift_cluster.test.name
  resource_group_name = azurerm_redhat_openshift_cluster.test.resource_group_name
  location            = azurerm_redhat_openshift_cluster.test.location

  cluster_profile {
    domain  = azurerm_redhat_openshift_cluster.test.cluster_profile.0.domain
    version = azurerm_redhat_openshift_cluster.test.cluster_profile.0.version
  }

  network_profile {
    pod_cidr     = azurerm_redhat_openshift_cluster.test.network_profile.0.pod_cidr
    service_cidr = azurerm_redhat_openshift_cluster.test.network_profile.0.service_cidr
  }

  main_profile {
    vm_size   = azurerm_redhat_openshift_cluster.test.main_profile.0.vm_size
    subnet_id = azurerm_redhat_openshift_cluster.test.main_profile.0.subnet_id
  }

  api_server_profile {
    visibility = azurerm_redhat_openshift_cluster.test.api_server_profile.0.visibility
  }

  ingress_profile {
    visibility = azurerm_redhat_openshift_cluster.test.ingress_profile.0.visibility
  }

  worker_profile {
    vm_size      = azurerm_redhat_openshift_cluster.test.worker_profile.0.vm_size
    disk_size_gb = azurerm_redhat_openshift_cluster.test.worker_profile.0.disk_size_gb
    node_count   = azurerm_redhat_openshift_cluster.test.worker_profile.0.node_count
    subnet_id    = azurerm_redhat_openshift_cluster.test.worker_profile.0.subnet_id
  }

  service_principal {
    client_id     = azurerm_redhat_openshift_cluster.test.service_principal.0.client_id
    client_secret = azurerm_redhat_openshift_cluster.test.service_principal.0.client_secret
  }

  depends_on = [
    "azurerm_role_assignment.role_network1",
    "azurerm_role_assignment.role_network2",
  ]
}
  