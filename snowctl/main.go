package main

import (
	"fmt"
	"strings"

	"context"
	"os"
	"time"

	"github.com/bketelsen/snow/snowctl/internal/features"
	"github.com/charmbracelet/fang"
	"github.com/spf13/cobra"
)

func main() {

	var now bool

	cmd := &cobra.Command{
		Use:   "snowctl [args]",
		Short: "An snowctl program!",
		Long: `Manage your snow system with snowctl.

It doesn’t really do anything, but that’s the point.™`,
		Example: `
# Run it:
snowctl

# Run it with some arguments:
FOO=bar ZAZ="quoted value" snowctl --name=Carlos -a -s Becker -a

# Run a subcommand with an argument:
snowctl sub --async --foo=xyz --async arguments

# Run with a quoted string:
snowctl sub "quoted string"

# Subcommand aliases:
snowctl s "subcommand alias"
snowctl subcommand "subcommand alias"
snowctl s another --thing

# Mix and match:
snowctl sub "multi-word quoted string" --name "another quoted string" -a

# Multi-line:
ENV_A=0 ENV_B=0 ENV_C=0 \
  CERT_FILE=/path/to/chain.pem KEY_FILE=/path/to/key.pem \
  snowctl sub "quoted argument"

# Run a subcommand's subcommand with an argument:
snowctl sub another args --flag

# Pipe snowctl:
echo "foo" | snowctl > bar.txt

# Redirects:
snowctl < in.txt > out.txt
snowctl 2>&1 1>/dev/null
snowctl 1>&2 2>/dev/null

# And / Or:
foo || snowctl
snowctl && foo

# Another pipe snowctl:
echo 'foo' |
  snowctl sub |
  cat -
		`,
		RunE: func(c *cobra.Command, _ []string) error {
			if now {
				fmt.Println("Applying changes now...")
			} else {
				fmt.Println("Changes will be applied on reboot.")
			}
			c.Println("You ran the root command. Now try --help.")
			return nil
		},
	}
	cmd.Flags().BoolP("async", "a", false, "Run async")
	cmd.Flags().BoolVarP(&now, "now", "n", false, "Apply changes now")

	cmd.AddGroup(&cobra.Group{
		ID:    "features",
		Title: "Manage Features",
	})
	cmd.AddGroup(&cobra.Group{
		ID:    "extensions",
		Title: "Manage Extensions",
	})
	sub := &cobra.Command{
		Use:     "feature [command] [flags] [args]",
		Aliases: []string{"f"},
		Short:   "Manage features",
		GroupID: "features",
		Run: func(c *cobra.Command, _ []string) {
			other()
		},
	}
	cmd.AddCommand(sub)
	sub.AddCommand(&cobra.Command{
		Use:   "another",
		Short: "another sub command",
		Example: `
snowctl sub another --foo=bar
snowctl subcommand "subcommand alias"
snowctl s another --thing
`,
		RunE: func(c *cobra.Command, _ []string) error {
			cmd.Println("Working...")
			select {
			case <-time.After(time.Second * 5):
				cmd.Println("Done!")
			case <-c.Context().Done():
				return c.Context().Err()
			}
			return nil
		},
	})

	cmd.AddCommand(&cobra.Command{
		Use:     "ext",
		Short:   "Extension management",
		GroupID: "extensions",
	})

	// This is where the magic happens.
	if err := fang.Execute(
		context.Background(),
		cmd,
		fang.WithNotifySignal(os.Interrupt, os.Kill),
	); err != nil {
		os.Exit(1)
	}
}

func other() {

	ff, err := features.ListFeatures()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error listing features:", err)
		os.Exit(1)
	}
	fmt.Println("Result from calling ListFeatures function on org.freedesktop.sysupdate1.Target.ListFeatures interface:")
	for _, feature := range ff {
		desc, err := features.DescribeFeature(feature)
		if err != nil {
			fmt.Fprintln(os.Stderr, "Error getting feature information:", err)
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
