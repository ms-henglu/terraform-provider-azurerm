package springcloud

import (
	"fmt"
	"log"
	"time"

	"github.com/hashicorp/go-azure-helpers/lang/response"
	"github.com/hashicorp/go-azure-sdk/resource-manager/appplatform/2022-09-01-preview/appplatform"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/tf"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/validation"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
)

func resourceSpringCloudStorage() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Create: resourceSpringCloudStorageCreateUpdate,
		Read:   resourceSpringCloudStorageRead,
		Update: resourceSpringCloudStorageCreateUpdate,
		Delete: resourceSpringCloudStorageDelete,

		Timeouts: &pluginsdk.ResourceTimeout{
			Create: pluginsdk.DefaultTimeout(30 * time.Minute),
			Read:   pluginsdk.DefaultTimeout(5 * time.Minute),
			Update: pluginsdk.DefaultTimeout(30 * time.Minute),
			Delete: pluginsdk.DefaultTimeout(30 * time.Minute),
		},

		Importer: pluginsdk.ImporterValidatingResourceId(func(id string) error {
			_, err := appplatform.ParseStorageIDInsensitively(id)
			return err
		}),

		Schema: map[string]*pluginsdk.Schema{
			"name": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"spring_cloud_service_id": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: appplatform.ValidateSpringID,
			},

			"storage_account_name": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"storage_account_key": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},
		},
	}
}
func resourceSpringCloudStorageCreateUpdate(d *pluginsdk.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	springCloudId, err := appplatform.ParseSpringIDInsensitively(d.Get("spring_cloud_service_id").(string))
	if err != nil {
		return err
	}

	id := appplatform.NewStorageID(subscriptionId, springCloudId.ResourceGroupName, springCloudId.ServiceName, d.Get("name").(string))

	if d.IsNewResource() {
		existing, err := client.StoragesGet(ctx, id)
		if err != nil {
			if !response.WasNotFound(existing.HttpResponse) {
				return fmt.Errorf("checking for existing %q: %+v", id, err)
			}
		}
		if !response.WasNotFound(existing.HttpResponse) {
			return tf.ImportAsExistsError("azurerm_spring_cloud_storage", id.ID())
		}
	}

	storageResource := appplatform.StorageResource{
		Properties: &appplatform.StorageAccount{
			AccountName: d.Get("storage_account_name").(string),
			AccountKey:  d.Get("storage_account_key").(string),
		},
	}
	err = client.StoragesCreateOrUpdateThenPoll(ctx, id, storageResource)
	if err != nil {
		return fmt.Errorf("creating/updating %q: %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceSpringCloudStorageRead(d, meta)
}

func resourceSpringCloudStorageRead(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := appplatform.ParseStorageIDInsensitively(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.StoragesGet(ctx, *id)
	if err != nil {
		if response.WasNotFound(resp.HttpResponse) {
			log.Printf("[INFO] %q does not exist - removing from state", id)
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving %q: %+v", id, err)
	}
	d.Set("name", id.StorageName)
	d.Set("spring_cloud_service_id", appplatform.NewSpringID(id.SubscriptionId, id.ResourceGroupName, id.ServiceName).ID())
	if resp.Model.Properties != nil {
		if props, ok := resp.Model.Properties.(appplatform.StorageAccount); ok {
			d.Set("storage_account_name", props.AccountName)
		}
	}
	return nil
}

func resourceSpringCloudStorageDelete(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).AppPlatform.AppPlatformClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := appplatform.ParseStorageIDInsensitively(d.Id())
	if err != nil {
		return err
	}

	err = client.StoragesDeleteThenPoll(ctx, *id)
	if err != nil {
		return fmt.Errorf("deleting %q: %+v", id, err)
	}

	return nil
}
