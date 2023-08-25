
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025303866638"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccogpnv"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "testspringcloudservice-ogpnv"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "testspringcloud-ogpnv"
  resource_group_name = azurerm_resource_group.test.name
  service_name        = azurerm_spring_cloud_service.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_spring_cloud_java_deployment" "test" {
  name                = "deploy-ogpnv"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
}

resource "azurerm_spring_cloud_connection" "test" {
  name               = "acctestserviceconnector230825025303866638"
  spring_cloud_id    = azurerm_spring_cloud_java_deployment.test.id
  target_resource_id = azurerm_storage_account.test.id
  authentication {
    type = "systemAssignedIdentity"
  }
}
