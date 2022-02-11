package backuppolicies

import (
	"encoding/json"
	"fmt"
	"strings"
)

type BackupParameters interface {
}

func unmarshalBackupParametersImplementation(input []byte) (BackupParameters, error) {
	if input == nil {
		return nil, nil
	}

	var temp map[string]interface{}
	if err := json.Unmarshal(input, &temp); err != nil {
		return nil, fmt.Errorf("unmarshaling BackupParameters into map[string]interface: %+v", err)
	}

	value, ok := temp["objectType"].(string)
	if !ok {
		return nil, nil
	}

	if strings.EqualFold(value, "AzureBackupParams") {
		var out AzureBackupParams
		if err := json.Unmarshal(input, &out); err != nil {
			return nil, fmt.Errorf("unmarshaling into AzureBackupParams: %+v", err)
		}
		return out, nil
	}

	type RawBackupParametersImpl struct {
		Type   string                 `json:"-"`
		Values map[string]interface{} `json:"-"`
	}
	out := RawBackupParametersImpl{
		Type:   value,
		Values: temp,
	}
	return out, nil

}
