package main

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/godbus/dbus/v5"
)

type FeatureDescription struct {
	Name          string   `json:"name"`
	Enabled       bool     `json:"enabled"`
	Description   string   `json:"description"`
	Documentation string   `json:"documentation"`
	Transfers     []string `json:"transfers"`
}

func main() {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to connect to system bus:", err)
		os.Exit(1)
	}
	defer conn.Close()

	var s []string
	obj := conn.Object("org.freedesktop.sysupdate1", "/org/freedesktop/sysupdate1/target/host")
	err = obj.Call("org.freedesktop.sysupdate1.Target.ListFeatures", 0, uint64(0)).Store(&s)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to call ListFeatures function (is the server example running?):", err)
		os.Exit(1)
	}

	fmt.Println("Result from calling ListFeatures function on org.freedesktop.sysupdate1.Target.ListFeatures interface:")
	for _, feature := range s {
		fmt.Println(" -", feature)

		var res string
		obj := conn.Object("org.freedesktop.sysupdate1", "/org/freedesktop/sysupdate1/target/host")
		err = obj.Call("org.freedesktop.sysupdate1.Target.DescribeFeature", 0, feature, uint64(0)).Store(&res)
		if err != nil {
			fmt.Fprintln(os.Stderr, "Failed to call DescribeFeature function (is the server example running?):", err)
			os.Exit(1)
		}

		var desc FeatureDescription
		err = json.Unmarshal([]byte(res), &desc)
		if err != nil {
			fmt.Fprintln(os.Stderr, "Failed to unmarshal JSON response:", err)
			os.Exit(1)
		}

		fmt.Println("   Name:", desc.Name)
		fmt.Println("   Enabled:", desc.Enabled)
		fmt.Println("   Description:", desc.Description)
		fmt.Println("   Documentation:", desc.Documentation)
		fmt.Println("   Transfers:")
		// if desc.Transfers is empty, print "    (none)"
		if len(desc.Transfers) == 0 {
			fmt.Println("    (none)")
		} else {
			for _, transfer := range desc.Transfers {
				fmt.Println("    -", transfer)
			}
		}

		fmt.Println("   Associated files in /var/lib/extensions:")
		// get a list of files in /var/lib/extensions that end in feature.raw
		files, err := os.ReadDir("/var/lib/extensions")
		if err != nil {
			fmt.Fprintln(os.Stderr, "Failed to read extensions directory:", err)
			os.Exit(1)
		}

		for _, file := range files {
			if file.IsDir() {
				continue
			}
			suffix := feature + ".raw"
			// check if the file ends with suffix
			if strings.HasSuffix(file.Name(), suffix) {
				fmt.Println("   -", file.Name())
			}
		}
	}
}
