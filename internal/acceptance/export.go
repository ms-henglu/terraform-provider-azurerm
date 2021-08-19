package acceptance

import (
	"fmt"
	"io/ioutil"
	"os"
	"runtime"
	"strings"
	"testing"

	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance/types"
)

func (td TestData) ExportConfig(t *testing.T, testResource types.TestResource, steps []TestStep) {
	workingDirectory, err := os.Getwd()
	if err != nil {
		t.Fatal(err)
	}
	workingDirectory = workingDirectory[:strings.Index(workingDirectory, "internal")]
	if runtime.GOOS == "windows" {
		workingDirectory += "export\\"
	} else {
		workingDirectory += "export/"
	}
	if _, err := os.Stat(workingDirectory); os.IsNotExist(err) {
		err = os.Mkdir(workingDirectory, 0744)
		if err != nil {
			t.Fatal(err)
		}
	}

	for i, step := range steps {
		if len(step.Config) > 0 {
			filename := fmt.Sprintf(workingDirectory+"%v_step_%v.tf", strings.ReplaceAll(t.Name(), "/", "_"), i)
			d1 := []byte(step.Config)
			err = ioutil.WriteFile(filename, d1, 0744)
			if err != nil {
				t.Fatalf("fail to write file: %v", err)
			} else {
				fmt.Printf("config exported to file : %v", filename)
			}
		}
	}
}
