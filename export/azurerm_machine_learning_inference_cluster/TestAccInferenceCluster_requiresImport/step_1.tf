


provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-230106034704912637"
  location = "West Europe"
  tags = {
    "stage" = "test"
  }
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-230106034704912637"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acctest23010603470491263"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled = true
}

resource "azurerm_storage_account" "test" {
  name                     = "acctest23010603470491263"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_machine_learning_workspace" "test" {
  name                    = "acctest-MLW2301060347049126"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  key_vault_id            = azurerm_key_vault.test.id
  storage_account_id      = azurerm_storage_account.test.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet230106034704912637"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet230106034704912637"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230106034704912637"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = join("", ["acctestaks", azurerm_resource_group.test.location])
  node_resource_group = "acctestRGAKS-230106034704912637"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.test.id
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_machine_learning_inference_cluster" "test" {
  name                          = "AIC-23010637"
  machine_learning_workspace_id = azurerm_machine_learning_workspace.test.id
  location                      = azurerm_resource_group.test.location
  kubernetes_cluster_id         = azurerm_kubernetes_cluster.test.id
  cluster_purpose               = "DevTest"


  tags = {
    ENV = "Test"
  }
}


resource "azurerm_machine_learning_inference_cluster" "import" {
  name                          = azurerm_machine_learning_inference_cluster.test.name
  machine_learning_workspace_id = azurerm_machine_learning_inference_cluster.test.machine_learning_workspace_id
  location                      = azurerm_machine_learning_inference_cluster.test.location
  kubernetes_cluster_id         = azurerm_machine_learning_inference_cluster.test.kubernetes_cluster_id
  cluster_purpose               = azurerm_machine_learning_inference_cluster.test.cluster_purpose

  tags = azurerm_machine_learning_inference_cluster.test.tags
}
