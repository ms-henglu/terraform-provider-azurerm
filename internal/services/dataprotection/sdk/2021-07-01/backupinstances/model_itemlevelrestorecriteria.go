package backupinstances

import (
	"encoding/json"
	"fmt"
	"strings"
)

type ItemLevelRestoreCriteria interface {
}

func unmarshalItemLevelRestoreCriteriaImplementation(input []byte) (ItemLevelRestoreCriteria, error) {
	if input == nil {
		return nil, nil
	}

	var temp map[string]interface{}
	if err := json.Unmarshal(input, &temp); err != nil {
		return nil, fmt.Errorf("unmarshaling ItemLevelRestoreCriteria into map[string]interface: %+v", err)
	}

	value, ok := temp["objectType"].(string)
	if !ok {
		return nil, nil
	}

	if strings.EqualFold(value, "RangeBasedItemLevelRestoreCriteria") {
		var out RangeBasedItemLevelRestoreCriteria
		if err := json.Unmarshal(input, &out); err != nil {
			return nil, fmt.Errorf("unmarshaling into RangeBasedItemLevelRestoreCriteria: %+v", err)
		}
		return out, nil
	}

	type RawItemLevelRestoreCriteriaImpl struct {
		Type   string                 `json:"-"`
		Values map[string]interface{} `json:"-"`
	}
	out := RawItemLevelRestoreCriteriaImpl{
		Type:   value,
		Values: temp,
	}
	return out, nil

}
