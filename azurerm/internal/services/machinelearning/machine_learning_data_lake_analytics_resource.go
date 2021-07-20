package machinelearning

import (
	"fmt"
	"log"
	"regexp"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/machinelearningservices/mgmt/2020-04-01/machinelearningservices"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/validation"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/tf"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/location"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/machinelearning/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/machinelearning/validate"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tags"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/pluginsdk"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/timeouts"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

func resourceDataLakeAnalytics() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Create: resourceDataLakeAnalyticsCreateUpdate,
		Update: resourceDataLakeAnalyticsCreateUpdate,
		Read:   resourceDataLakeAnalyticsRead,
		Delete: resourceDataLakeAnalyticsDelete,

		Importer: pluginsdk.ImporterValidatingResourceId(func(id string) error {
			_, err := parse.ComputeID(id)
			return err
		}),

		Timeouts: &pluginsdk.ResourceTimeout{
			Create: pluginsdk.DefaultTimeout(30 * time.Minute),
			Read:   pluginsdk.DefaultTimeout(5 * time.Minute),
			Delete: pluginsdk.DefaultTimeout(30 * time.Minute),
		},

		Schema: map[string]*pluginsdk.Schema{
			"name": {
				Type:     pluginsdk.TypeString,
				Required: true,
				ForceNew: true,
				ValidateFunc: validation.StringMatch(
					regexp.MustCompile(`^[a-zA-Z][a-zA-Z0-9-]{2,16}$`),
					"It can include letters, digits and dashes. It must start with a letter, end with a letter or digit, and be between 2 and 16 characters in length."),
			},

			"machine_learning_workspace_id": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validate.WorkspaceID,
			},

			"location": azure.SchemaLocation(),

			"data_lake_analytics_account_id": {
				Type:     pluginsdk.TypeString,
				Required: true,
				ForceNew: true,
			},

			"data_lake_store_account_name": {
				Type:     pluginsdk.TypeString,
				Optional: true,
			},

			"description": {
				Type:     pluginsdk.TypeString,
				Optional: true,
				ForceNew: true,
			},

			"identity": SystemAssignedUserAssigned{}.Schema(),

			"tags": tags.ForceNewSchema(),
		},
	}
}

func resourceDataLakeAnalyticsCreateUpdate(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).MachineLearning.MachineLearningComputeClient
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	ctx, cancel := timeouts.ForCreate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	workspaceID, _ := parse.WorkspaceID(d.Get("machine_learning_workspace_id").(string))
	id := parse.NewComputeID(subscriptionId, workspaceID.ResourceGroup, workspaceID.Name, d.Get("name").(string))

	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.WorkspaceName, id.Name)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Machine Learning Compute (%q): %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_machine_learning_data_lake_analytics", id.ID())
		}
	}

	identity, err := SystemAssignedUserAssigned{}.Expand(d.Get("identity").([]interface{}))
	if err != nil {
		return err
	}
	computeParameters := machinelearningservices.ComputeResource{
		Properties: machinelearningservices.DataLakeAnalytics{
			ResourceID:      utils.String(d.Get("data_lake_analytics_account_id").(string)),
			ComputeLocation: utils.String(d.Get("location").(string)),
			Description:     utils.String(d.Get("description").(string)),
			Properties: &machinelearningservices.DataLakeAnalyticsProperties{
				DataLakeStoreAccountName: utils.String(d.Get("data_lake_store_account_name").(string)),
			},
		},
		Identity: identity,
		Location: utils.String(location.Normalize(d.Get("location").(string))),
		Tags:     tags.Expand(d.Get("tags").(map[string]interface{})),
	}

	future, err := client.CreateOrUpdate(ctx, id.ResourceGroup, id.WorkspaceName, id.Name, computeParameters)
	if err != nil {
		return fmt.Errorf("creating Machine Learning Compute (%q): %+v", id, err)
	}
	if err := future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for creation of Machine Learning Compute (%q): %+v", id, err)
	}

	d.SetId(id.ID())

	return resourceDataLakeAnalyticsRead(d, meta)
}

func resourceDataLakeAnalyticsRead(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).MachineLearning.MachineLearningComputeClient
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.ComputeID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.WorkspaceName, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] Machine Learning Compute %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Machine Learning Compute (%q): %+v", id, err)
	}

	d.Set("name", id.Name)
	workspaceId := parse.NewWorkspaceID(subscriptionId, id.ResourceGroup, id.WorkspaceName)
	d.Set("machine_learning_workspace_id", workspaceId.ID())

	if location := resp.Location; location != nil {
		d.Set("location", azure.NormalizeLocation(*location))
	}

	identity, err := SystemAssignedUserAssigned{}.Flatten(resp.Identity)
	if err != nil {
		return err
	}
	d.Set("identity", identity)

	if props, ok := resp.Properties.AsDataLakeAnalytics(); ok && props != nil {
		d.Set("data_lake_analytics_account_id", props.ResourceID)
		d.Set("description", props.Description)
		if props.Properties != nil {
			//d.Set("data_lake_store_account_name", props.Properties.DataLakeStoreAccountName)
		}
	} else {
		return fmt.Errorf("compute resource %s is not a Data Lake Analytics Compute", id)
	}

	return tags.FlattenAndSet(d, resp.Tags)
}

func resourceDataLakeAnalyticsDelete(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).MachineLearning.MachineLearningComputeClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()
	id, err := parse.ComputeID(d.Id())
	if err != nil {
		return err
	}

	future, err := client.Delete(ctx, id.ResourceGroup, id.WorkspaceName, id.Name, machinelearningservices.Detach)
	if err != nil {
		return fmt.Errorf("deleting Machine Learning Compute (%q): %+v", id, err)
	}

	if err := future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for deletion of the Machine Learning Compute (%q): %+v", id, err)
	}
	return nil
}
