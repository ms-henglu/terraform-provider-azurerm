package dataprotection

import (
	"fmt"
	"log"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/dataprotection/mgmt/2021-01-01/dataprotection"
	"github.com/hashicorp/go-azure-helpers/response"
	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/tf"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/location"
	computeParse "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/compute/parse"
	computeValidate "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/compute/validate"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/dataprotection/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/dataprotection/validate"
	resourceParse "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/resource/parse"
	azSchema "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/timeouts"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

func resourceDataProtectionBackupInstanceDisk() *schema.Resource {
	return &schema.Resource{
		Create: resourceDataProtectionBackupInstanceDiskCreateUpdate,
		Read:   resourceDataProtectionBackupInstanceDiskRead,
		Update: resourceDataProtectionBackupInstanceDiskCreateUpdate,
		Delete: resourceDataProtectionBackupInstanceDiskDelete,

		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.BackupInstanceID(id)
			return err
		}),

		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

			"resource_group_name": azure.SchemaResourceGroupName(),

			"location": location.Schema(),

			"vault_name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

			"disk_id": {
				Type:         schema.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: computeValidate.ManagedDiskID,
			},

			"snapshot_resource_group_name": azure.SchemaResourceGroupName(),

			"policy_id": {
				Type:         schema.TypeString,
				Required:     true,
				ValidateFunc: validate.BackupPolicyID,
			},
		},
	}
}
func resourceDataProtectionBackupInstanceDiskCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).DataProtection.BackupInstanceClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)
	vaultName := d.Get("vault_name").(string)

	id := parse.NewBackupInstanceID(subscriptionId, resourceGroup, vaultName, name)

	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.BackupVaultName, id.ResourceGroup, id.Name)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing DataProtection BackupInstance (%q): %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_data_protection_backup_instance_disk", id.ID())
		}
	}

	diskId, _ := computeParse.ManagedDiskID(d.Get("disk_id").(string))
	location := location.Normalize(d.Get("location").(string))
	policyId, _ := parse.BackupPolicyID(d.Get("policy_id").(string))
	snapshotResourceGroupId := resourceParse.NewResourceGroupID(subscriptionId, d.Get("snapshot_resource_group_name").(string))

	parameters := dataprotection.BackupInstanceResource{
		Properties: &dataprotection.BackupInstance{
			DataSourceInfo: &dataprotection.Datasource{
				DatasourceType:   utils.String("Microsoft.Compute/disks"),
				ObjectType:       utils.String("Datasource"),
				ResourceID:       utils.String(diskId.ID()),
				ResourceLocation: utils.String(location),
				ResourceName:     utils.String(diskId.DiskName),
				ResourceType:     utils.String("Microsoft.Compute/disks"),
				ResourceURI:      utils.String(diskId.ID()),
			},
			FriendlyName: utils.String(id.Name),
			PolicyInfo: &dataprotection.PolicyInfo{
				PolicyID: utils.String(policyId.ID()),
				PolicyParameters: &dataprotection.PolicyParameters{
					DataStoreParametersList: &[]dataprotection.BasicDataStoreParameters{
						dataprotection.AzureOperationalStoreParameters{
							ResourceGroupID: utils.String(snapshotResourceGroupId.ID()),
							DataStoreType:   dataprotection.OperationalStore,
							ObjectType:      dataprotection.ObjectTypeAzureOperationalStoreParameters,
						},
					},
				},
			},
		},
	}

	future, err := client.CreateOrUpdate(ctx, id.BackupVaultName, id.ResourceGroup, id.Name, parameters)
	if err != nil {
		return fmt.Errorf("creating/updating DataProtection BackupInstance (%q): %+v", id, err)
	}

	if err := future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for creation/update of the DataProtection BackupInstance (%q): %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceDataProtectionBackupInstanceDiskRead(d, meta)
}

func resourceDataProtectionBackupInstanceDiskRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).DataProtection.BackupInstanceClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.BackupInstanceID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.BackupVaultName, id.ResourceGroup, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] dataprotection %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving DataProtection BackupInstance (%q): %+v", id, err)
	}
	d.Set("name", id.Name)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("vault_name", id.BackupVaultName)
	if props := resp.Properties; props != nil {
		if props.DataSourceInfo != nil {
			d.Set("disk_id", props.DataSourceInfo.ResourceID)
			d.Set("location", props.DataSourceInfo.ResourceLocation)
		}
		if props.PolicyInfo != nil {
			d.Set("policy_id", props.PolicyInfo.PolicyID)
			if props.PolicyInfo.PolicyParameters != nil && props.PolicyInfo.PolicyParameters.DataStoreParametersList != nil && len(*props.PolicyInfo.PolicyParameters.DataStoreParametersList) > 0 {
				if parameter, ok := (*props.PolicyInfo.PolicyParameters.DataStoreParametersList)[0].AsAzureOperationalStoreParameters(); ok {
					if parameter.ResourceGroupID != nil {
						resourceGroupId, err := resourceParse.ResourceGroupID(*parameter.ResourceGroupID)
						if err != nil {
							return err
						}
						d.Set("snapshot_resource_group_name", resourceGroupId.ResourceGroup)
					}
				}
			}
		}
	}
	return nil
}

func resourceDataProtectionBackupInstanceDiskDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).DataProtection.BackupInstanceClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.BackupInstanceID(d.Id())
	if err != nil {
		return err
	}

	future, err := client.Delete(ctx, id.BackupVaultName, id.ResourceGroup, id.Name)
	if err != nil {
		if response.WasNotFound(future.Response()) {
			return nil
		}
		return fmt.Errorf("deleting DataProtection BackupInstance (%q): %+v", id, err)
	}

	if err := future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for deletion of the DataProtection BackupInstance (%q): %+v", id.Name, err)
	}
	return nil
}
