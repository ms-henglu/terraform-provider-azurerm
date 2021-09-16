package synapse

import (
	"encoding/json"
	"fmt"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
	"log"
	"net/http"
	"time"

	"github.com/hashicorp/terraform-provider-azurerm/helpers/tf"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/validation"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
)

func resourceAzureGenericResource() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Create: resourceAzureGenericResourceCreateUpdate,
		Read:   resourceAzureGenericResourceRead,
		Update: resourceAzureGenericResourceCreateUpdate,
		Delete: resourceAzureGenericResourceDelete,

		Importer: pluginsdk.DefaultImporter(),

		Timeouts: &pluginsdk.ResourceTimeout{
			Create: pluginsdk.DefaultTimeout(30 * time.Minute),
			Read:   pluginsdk.DefaultTimeout(5 * time.Minute),
			Update: pluginsdk.DefaultTimeout(30 * time.Minute),
			Delete: pluginsdk.DefaultTimeout(30 * time.Minute),
		},

		Schema: map[string]*pluginsdk.Schema{
			"url": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"api_version": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"body": {
				Type:             pluginsdk.TypeString,
				Required:         true,
				ValidateFunc:     validation.StringIsJSON,
				DiffSuppressFunc: suppressJsonOrderingDifference1,
			},

			"create_method": {
				Type:         pluginsdk.TypeString,
				Optional:     true,
				Default:      "PUT",
				ValidateFunc: validation.StringInSlice([]string{"POST", "PUT"}, false),
			},

			"update_method": {
				Type:         pluginsdk.TypeString,
				Optional:     true,
				Default:      "PUT",
				ValidateFunc: validation.StringInSlice([]string{"POST", "PUT", "PATCH"}, false),
			},

			"response_body": {
				Type:     pluginsdk.TypeString,
				Computed: true,
			},
		},
	}
}

func resourceAzureGenericResourceCreateUpdate(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Synapse.CommonClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	url := d.Get("url").(string)
	apiVersion := d.Get("api_version").(string)

	if d.IsNewResource() {
		existing, response, err := client.Get(ctx, url, apiVersion)
		if err != nil {
			if response.StatusCode != http.StatusNotFound {
				return fmt.Errorf("checking for presence of existing %s: %+v", url, err)
			}
		}
		if existing != nil && len(existing.(map[string]interface{})["id"].(string)) > 0 {
			return tf.ImportAsExistsError("azurerm_generic_resource", existing.(map[string]interface{})["id"].(string))
		}
	}

	var requestBody interface{}
	err := json.Unmarshal([]byte(d.Get("body").(string)), &requestBody)
	if err != nil {
		return err
	}

	_, _, err = client.Put(ctx, url, apiVersion, requestBody)
	if err != nil {
		return fmt.Errorf("creating/updating %q: %+v", url, err)
	}

	d.SetId(url)

	return resourceAzureGenericResourceRead(d, meta)
}

func resourceAzureGenericResourceRead(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Synapse.CommonClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	url := d.Get("url").(string)
	apiVersion := d.Get("api_version").(string)

	responseBody, response, err := client.Get(ctx, url, apiVersion)
	if err != nil {
		if response.StatusCode == http.StatusNotFound {
			log.Printf("[INFO] Error reading %q - removing from state", d.Id())
			d.SetId("")
			return nil
		}

		return fmt.Errorf("reading %q: %+v", url, err)
	}

	d.Set("url", url)
	d.Set("api_version", apiVersion)

	bodyJson := d.Get("body").(string)
	var requestBody interface{}
	err = json.Unmarshal([]byte(bodyJson), &requestBody)
	if err != nil {
		return err
	}
	data, err := json.Marshal(getUpdatedJson(requestBody, responseBody))
	if err != nil {
		return err
	}
	d.Set("body", string(data))

	responseBodyJson, err := json.Marshal(responseBody)
	d.Set("response_body", string(responseBodyJson))
	return nil
}

func resourceAzureGenericResourceDelete(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Synapse.CommonClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	url := d.Get("url").(string)
	apiVersion := d.Get("api_version").(string)

	_, _, err := client.Delete(ctx, url, apiVersion)
	if err != nil {
		return fmt.Errorf("deleting %q: %+v", url, err)
	}

	return nil
}

func suppressJsonOrderingDifference1(_, old, new string, _ *pluginsdk.ResourceData) bool {
	return utils.NormalizeJson(old) == utils.NormalizeJson(new)
}

func getUpdatedJson(old interface{}, new interface{}) interface{} {
	switch old.(type) {
	case map[string]interface{}:
		switch new.(type) {
		case map[string]interface{}:
			oldMap := old.(map[string]interface{})
			newMap := new.(map[string]interface{})
			res := make(map[string]interface{})
			for key, oldValue := range oldMap {
				if newMap[key] != nil {
					res[key] = getUpdatedJson(oldValue, newMap[key])
				}
			}
			return res
		default:
			return new
		}
	case []interface{}:
		switch new.(type) {
		case []interface{}:
			oldArr := old.([]interface{})
			newArr := new.([]interface{})
			if len(oldArr) != len(newArr) {
				return newArr
			}
			res := make([]interface{}, 0)
			for index := range oldArr {
				res = append(res, getUpdatedJson(oldArr[index], newArr[index]))
			}
			return res
		default:
			return new
		}
	default:
		return new
	}
}
