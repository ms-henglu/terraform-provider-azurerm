---
subcategory: "Monitor"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_monitor_data_collection_rule_association"
description: |-
  Manages a Data Collection Rule Association.
---

# azurerm_monitor_data_collection_rule_association

Manages a Data Collection Rule Association.

## Example Usage

```hcl
resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_rule" "example" {
  name                = "example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  azure_monitor_metrics_destination {
    name = "example"
  }

  windows_event_log_data_source {
    name          = "cloudSecurityTeamEvents"
    streams       = ["Microsoft-WindowsEvent"]
    xpath_queries = ["Security!"]
  }

  data_flows {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["example"]
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  ip_configuration {
    name                          = "example"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "example" {
  name                  = "example"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.example.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_monitor_data_collection_rule_association" "example" {
  name                    = "example"
  virtual_machine_id      = azurerm_virtual_machine.example.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.example.id
}
```

## Arguments Reference

The following arguments are supported:

* `name` - (Required) The name which should be used for this Data Collection Rule Association. Changing this forces a new Data Collection Rule Association to be created.

* `virtual_machine_id` - (Required) The ID of the virtual machine. Changing this forces a new Data Collection Rule Association to be created.

---

* `data_collection_endpoint_id` - (Optional) The resource ID of the data collection endpoint that is to be associated.

* `data_collection_rule_id` - (Optional) The resource ID of the data collection rule that is to be associated.

* `description` - (Optional) Description of the association.

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported: 

* `id` - The ID of the Data Collection Rule Association.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating the Data Collection Rule Association.
* `read` - (Defaults to 5 minutes) Used when retrieving the Data Collection Rule Association.
* `update` - (Defaults to 30 minutes) Used when updating the Data Collection Rule Association.
* `delete` - (Defaults to 30 minutes) Used when deleting the Data Collection Rule Association.

## Import

Data Collection Rule Associations can be imported using the `resource id`, e.g.

```shell
terraform import azurerm_monitor_data_collection_rule_association.example C:/Program Files/Git/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/virtualMachine1/providers/Microsoft.Insights/dataCollectionRuleAssociations/association1
```
