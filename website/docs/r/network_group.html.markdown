---
subcategory: "Network"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_network_group"
description: |-
  Manages a network Group.
---

# azurerm_network_group

Manages a network Group.

## Example Usage

```hcl
resource "azurerm_resource_group" "example" {
  name     = "example-network"
  location = "West Europe"
}

resource "azurerm_network_manager" "example" {
  name = "example-manager"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
}

resource "azurerm_storage_account" "example" {
  name                     = "examplesads"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_network_service_endpoint_policy" "example" {
  name = "example-serviceendpointpolicy"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
}

resource "azurerm_network_virtual_network" "example" {
  name = "example-virtualnetwork"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
}

resource "azurerm_network_group" "example" {
  name = "example-group"
  resource_group_name = azurerm_resource_group.example.name
  network_manager_name = azurerm_network_manager.example.name
}
```

## Arguments Reference

The following arguments are supported:

* `name` - (Required) The name which should be used for this network Group. Changing this forces a new network Group to be created.

* `resource_group_name` - (Required) The name of the Resource Group where the network Group should exist. Changing this forces a new network Group to be created.

* `network_manager_name` - (Required) The name of the network manager. Changing this forces a new network Group to be created.

---

* `conditional_membership` - (Optional) Network group conditional filter.

* `description` - (Optional) A description of the network group.

* `display_name` - (Optional) A friendly name for the network group.

* `group_members` - (Optional) A `group_members` block as defined below.

* `member_type` - (Optional) Group member type. Possible values are "VirtualNetwork" and "Subnet" is allowed.

---

An `group_members` block exports the following:

* `resource_id` - (Optional) The ID of the resource.

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported:

* `id` - The ID of the network Group.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating the network Group.
* `read` - (Defaults to 5 minutes) Used when retrieving the network Group.
* `delete` - (Defaults to 30 minutes) Used when deleting the network Group.

## Import

network Groups can be imported using the `resource id`, e.g.

```shell
terraform import azurerm_network_group.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Network/networkManagers/networkManager1/networkGroups/networkGroup1
```