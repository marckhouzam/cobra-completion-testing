package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"
)

var (
	completions = []string{"bear\tan animal", "bearpaw\ta dessert", "dog\ta canine", "unicorn\tmythical"}
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
	Use:   "filext",
	Short: "Directive: fileext",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"yaml", "json"}, cobra.ShellCompDirectiveFilterFileExt
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

// ======================================================
// Command that completes on the contents of the 'dir' directory
// ======================================================
var subDirCmdPrefix = &cobra.Command{
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
var errorCmdPrefix = &cobra.Command{
	Use:   "error",
	Short: "Directive: error",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return completions, cobra.ShellCompDirectiveError
	},
	Run: func(cmd *cobra.Command, args []string) {},
}

func setFlags() {
	// rootCmd.Flags().String("theme", "", "theme to use (located in /themes/THEMENAME/)")
	// rootCmd.Flags().SetAnnotation("theme", cobra.BashCompSubdirsInDir, []string{"themes"})

	// rootCmd.Flags().String("theme2", "", "theme to use (located in /themes/THEMENAME/)")
	// rootCmd.RegisterFlagCompletionFunc("theme2", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	// 	return []string{"themes"}, cobra.ShellCompDirectiveFilterDirs
	// })

	// rootCmd.Flags().String("customComp", "", "test custom comp for flags")
	// rootCmd.RegisterFlagCompletionFunc("customComp", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	// 	return []string{"firstComp\tthe first value", "secondComp\tthe second value", "forthComp\tthe forth value"}, cobra.ShellCompDirectiveNoFileComp
	// })

	// rootCmd.Flags().StringP("file", "f", "", "list files")
	// rootCmd.Flags().String("longdesc", "", "before newline\nafter newline")

	// rootCmd.Flags().BoolP("bool", "b", false, "bool flag")
	// rootCmd.Flags().BoolSliceP("bslice", "B", nil, "bool slice flag")

	// rootCmd.PersistentFlags().StringP("persistent", "p", "", "persistent flag")

	// // rootCmd.Flags().String("required", "", "required flag")
	// // rootCmd.MarkFlagRequired("required")

	// vargsCmd.Flags().StringP("nonpersistent", "n", "", "non persistent local flag")

	// // If there is only a recommended value before we reach the equal sign or the colon, then the completion works as expected.
	// // If the values differ afterwards, completion fails in bash, but works in fish and zsh
	// rootCmd.Flags().String("equalSignWorks", "", "test custom comp with equal sign")
	// rootCmd.RegisterFlagCompletionFunc("equalSignWorks", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	// 	return []string{"first=Comp\tthe first value", "second=Comp\tthe second value", "forth=Comp\tthe forth value"}, cobra.ShellCompDirectiveNoFileComp
	// })

	// rootCmd.Flags().String("equalSignWorksNot", "", "test custom comp with equal sign")
	// rootCmd.RegisterFlagCompletionFunc("equalSignWorksNot", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	// 	return []string{"first=Comp1\tthe first value", "first=Comp2\tthe second value", "first=Comp3\tthe forth value"}, cobra.ShellCompDirectiveNoFileComp
	// })

	// rootCmd.Flags().String("colonWorks", "", "test custom comp with colon one value works")
	// rootCmd.RegisterFlagCompletionFunc("colonWorks", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	// 	return []string{"first:ONE\tthe first value", "second\tthe second value", "forth\tthe forth value"}, cobra.ShellCompDirectiveNoFileComp
	// })

	// rootCmd.Flags().String("colonWorksNot", "", "test custom comp with colon doesnt work")
	// rootCmd.RegisterFlagCompletionFunc("colonWorksNot", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	// 	return []string{"first:ONE\tthe first value", "first:SECOND\tthe second value", "second:Comp1\tthe forth value"}, cobra.ShellCompDirectiveNoFileComp
	// })

	// rootCmd.Flags().String("nospace", "", "test custom comp with nospace directive")
	// rootCmd.RegisterFlagCompletionFunc("nospace", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	// 	return []string{"complete\tFirst comp", "compost\tsecondComp"}, cobra.ShellCompDirectiveNoSpace
	// })

	// rootCmd.Flags().StringArray("array", []string{"allo", "toi"}, "string array flag")

	// flagA = withflagsCmd.Flags().BoolP("boolA", "a", false, "bool flag 1")
	// flagB = withflagsCmd.Flags().BoolP("boolB", "b", false, "bool flag 2")
	// flagC = withflagsCmd.Flags().BoolP("boolC", "c", false, "bool flag 3")
	// flagD = withflagsCmd.Flags().BoolP("boolD", "d", false, "bool flag 4")
	// flagS = withflagsCmd.Flags().StringP("string", "s", "", "string flag")
	// withflagsCmd.RegisterFlagCompletionFunc("string", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	// 	return []string{"complete\tFirst comp", "compost\tsecondComp"}, cobra.ShellCompDirectiveNoFileComp
	// })
}

func main() {
	rootCmd.AddCommand(newCompletionCmd(os.Stdout))
	setFlags()

	rootCmd.AddCommand(
		prefixCmd,
		noPrefixCmd,
		fileExtCmdPrefix,
		subDirCmdPrefix,
		errorCmdPrefix,
	)

	prefixCmd.AddCommand(
		noSpaceCmdPrefix,
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
