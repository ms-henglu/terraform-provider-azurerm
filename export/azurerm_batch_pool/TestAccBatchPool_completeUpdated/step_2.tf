
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230825024120200653"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "testaccsadxdzw"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                                = "testaccbatchdxdzw"
  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  pool_allocation_mode                = "BatchService"
  storage_account_id                  = azurerm_storage_account.test.id
  storage_account_authentication_mode = "StorageKeys"

  tags = {
    env = "test"
  }
}

resource "azurerm_batch_pool" "test" {
  name                          = "testaccpooldxdzw"
  resource_group_name           = azurerm_resource_group.test.name
  account_name                  = azurerm_batch_account.test.name
  display_name                  = "Test Acc Pool"
  vm_size                       = "Standard_A1"
  node_agent_sku_id             = "batch.node.ubuntu 18.04"
  stop_pending_resize_operation = true

  auto_scale {
    evaluation_interval = "PT15M"

    formula = <<EOF
      startingNumberOfVMs = 1;
      maxNumberofVMs = 25;
      pendingTaskSamplePercent = $PendingTasks.GetSamplePercent(180 * TimeInterval_Second);
      pendingTaskSamples = pendingTaskSamplePercent < 70 ? startingNumberOfVMs : avg($PendingTasks.GetSample(180 * TimeInterval_Second));
      $TargetDedicatedNodes=min(maxNumberofVMs, pendingTaskSamples);
EOF

  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-lts"
    version   = "latest"
  }
}
