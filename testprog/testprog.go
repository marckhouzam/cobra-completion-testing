package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"
)

var (
	completions      = []string{"bear\tan animal", "bearpaw\ta dessert", "dog", "unicorn\tmythical"}
	specialCharComps = []string{"at@", "equal=", "slash/", "colon:", "period.", "comma,", "letter"}
)

func getCompsFilteredByPrefix(prefix string) []string {
	var finalComps []string
	for _, comp := range completions {
		if strings.HasPrefix(comp, prefix) {
			finalComps = append(finalComps, comp)
		}
	}
	return finalComps
}

var rootCmd = &cobra.Command{
	Use: "testprog",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("rootCmd called")
	},
}

// ======================================================
// Set of commands that filter on the 'toComplete' prefix
// ======================================================
var prefixCmd = &cobra.Command{
	Use:   "prefix",
	Short: "completions filtered on prefix",
}

var defaultCmdPrefix = &cobra.Command{
	Use:   "default",
	Short: "Directive: default",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return getCompsFilteredByPrefix(toComplete), cobra.ShellCompDirectiveDefault
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

var noSpaceCmdPrefix = &cobra.Command{
	Use:   "nospace",
	Short: "Directive: no space",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return getCompsFilteredByPrefix(toComplete), cobra.ShellCompDirectiveNoSpace
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

var noSpaceCharCmdPrefix = &cobra.Command{
	Use:   "nospacechar",
	Short: "Directive: no space, with comp ending with special char @=/:.,",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		var finalComps []string
		for _, comp := range specialCharComps {
			if strings.HasPrefix(comp, toComplete) {
				finalComps = append(finalComps, comp)
			}
		}
		return finalComps, cobra.ShellCompDirectiveNoSpace
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

var noFileCmdPrefix = &cobra.Command{
	Use:   "nofile",
	Short: "Directive: nofilecomp",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return getCompsFilteredByPrefix(toComplete), cobra.ShellCompDirectiveNoFileComp
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

var noFileNoSpaceCmdPrefix = &cobra.Command{
	Use:   "nofilenospace",
	Short: "Directive: nospace and nofilecomp",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return getCompsFilteredByPrefix(toComplete), cobra.ShellCompDirectiveNoFileComp | cobra.ShellCompDirectiveNoSpace
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

// ======================================================
// Set of commands that do not filter on prefix
// ======================================================
var noPrefixCmd = &cobra.Command{
	Use:   "noprefix",
	Short: "completions NOT filtered on prefix",
}

var noSpaceCmdNoPrefix = &cobra.Command{
	Use:   "nospace",
	Short: "Directive: no space",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return completions, cobra.ShellCompDirectiveNoSpace
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

var noFileCmdNoPrefix = &cobra.Command{
	Use:   "nofile",
	Short: "Directive: nofilecomp",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return completions, cobra.ShellCompDirectiveNoFileComp
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

var noFileNoSpaceCmdNoPrefix = &cobra.Command{
	Use:   "nofilenospace",
	Short: "Directive: nospace and nofilecomp",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return completions, cobra.ShellCompDirectiveNoFileComp | cobra.ShellCompDirectiveNoSpace
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

var defaultCmdNoPrefix = &cobra.Command{
	Use:   "default",
	Short: "Directive: default",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return completions, cobra.ShellCompDirectiveDefault
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

// ======================================================
// Command that completes on file extension
// ======================================================
var fileExtCmdPrefix = &cobra.Command{
	Use:   "fileext",
	Short: "Directive: fileext",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"yaml", "json"}, cobra.ShellCompDirectiveFilterFileExt
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

// ======================================================
// Command that completes on the directories within the current directory
// ======================================================
var dirCmd = &cobra.Command{
	Use:   "dir",
	Short: "Directive: subdir",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return nil, cobra.ShellCompDirectiveFilterDirs
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

// ======================================================
// Command that completes on the directories within the 'dir' directory
// ======================================================
var subDirCmd = &cobra.Command{
	Use:   "subdir",
	Short: "Directive: subdir",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"dir"}, cobra.ShellCompDirectiveFilterDirs
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

// ======================================================
// Command that returns an error on completion
// ======================================================
var errorCmd = &cobra.Command{
	Use:   "error",
	Short: "Directive: error",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return completions, cobra.ShellCompDirectiveError
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

// ======================================================
// Command that wants an argument starting with a --
// Such an argument is possible following a '--'
// ======================================================
var dashArgCmd = &cobra.Command{
	Use:   "dasharg",
	Short: "Wants argument --arg",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"--arg\tan arg starting with dashes"}, cobra.ShellCompDirectiveDefault
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

func setFlags() {
	rootCmd.Flags().String("customComp", "", "test custom comp for flags")
	rootCmd.RegisterFlagCompletionFunc("customComp", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"firstComp\tthe first value", "secondComp\tthe second value", "forthComp"}, cobra.ShellCompDirectiveNoFileComp
	})

	rootCmd.Flags().String("theme", "", "theme to use (located in /dir/THEMENAME/)")
	rootCmd.Flags().SetAnnotation("theme", cobra.BashCompSubdirsInDir, []string{"dir"})

	dashArgCmd.Flags().Bool("flag", false, "a flag")
}

func main() {
	rootCmd.AddCommand(newCompletionCmd(os.Stdout))
	setFlags()

	rootCmd.AddCommand(
		prefixCmd,
		noPrefixCmd,
		fileExtCmdPrefix,
		dirCmd,
		subDirCmd,
		errorCmd,
		dashArgCmd,
	)

	prefixCmd.AddCommand(
		noSpaceCmdPrefix,
		noSpaceCharCmdPrefix,
		noFileCmdPrefix,
		noFileNoSpaceCmdPrefix,
		defaultCmdPrefix,
	)

	noPrefixCmd.AddCommand(
		noSpaceCmdNoPrefix,
		noFileCmdNoPrefix,
		noFileNoSpaceCmdNoPrefix,
		defaultCmdNoPrefix,
	)

	rootCmd.Execute()
}
