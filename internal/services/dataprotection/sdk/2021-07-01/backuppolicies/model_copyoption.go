package backuppolicies

import (
	"encoding/json"
	"fmt"
	"strings"
)

type CopyOption interface {
}

func unmarshalCopyOptionImplementation(input []byte) (CopyOption, error) {
	if input == nil {
		return nil, nil
	}

	var temp map[string]interface{}
	if err := json.Unmarshal(input, &temp); err != nil {
		return nil, fmt.Errorf("unmarshaling CopyOption into map[string]interface: %+v", err)
	}

	value, ok := temp["objectType"].(string)
	if !ok {
		return nil, nil
	}

	if strings.EqualFold(value, "CopyOnExpiryOption") {
		var out CopyOnExpiryOption
		if err := json.Unmarshal(input, &out); err != nil {
			return nil, fmt.Errorf("unmarshaling into CopyOnExpiryOption: %+v", err)
		}
		return out, nil
	}

	if strings.EqualFold(value, "CustomCopyOption") {
		var out CustomCopyOption
		if err := json.Unmarshal(input, &out); err != nil {
			return nil, fmt.Errorf("unmarshaling into CustomCopyOption: %+v", err)
		}
		return out, nil
	}

	if strings.EqualFold(value, "ImmediateCopyOption") {
		var out ImmediateCopyOption
		if err := json.Unmarshal(input, &out); err != nil {
			return nil, fmt.Errorf("unmarshaling into ImmediateCopyOption: %+v", err)
		}
		return out, nil
	}

	type RawCopyOptionImpl struct {
		Type   string                 `json:"-"`
		Values map[string]interface{} `json:"-"`
	}
	out := RawCopyOptionImpl{
		Type:   value,
		Values: temp,
	}
	return out, nil

}
