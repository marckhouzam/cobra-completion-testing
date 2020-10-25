package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"
)

var (
	flagA *bool
	flagB *bool
	flagC *bool
	flagD *bool
	flagS *string
)
var rootCmd = &cobra.Command{
	Use: "testprog",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("rootCmd called")
	},
}

var vargsCmd = &cobra.Command{
	Use:        "vargs",
	Short:      "Cmd with ValidArgs AND a subcmd",
	ValidArgs:  []string{"one", "two", "three"},
	ArgAliases: []string{"un", "deux", "trois"},
	Args:       cobra.MinimumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("vargsCmd called")
	},
}

var childVargsCmd = &cobra.Command{
	Use:   "childVargs",
	Short: "Child command",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("childVargs called")
	},
}

var aliasCmd = &cobra.Command{
	Use:     "cmdWithAlias",
	Short:   "Command with aliases",
	Aliases: []string{"aliasCmd", "cmdAlias"},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("cmdWithAlias called")
	},
}

// A command with no short description
var nodescriptionCmd = &cobra.Command{
	Use: "nodesc",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("nodesc called")
	},
}

// File filtering for the first argument
// Replaces MarkZshCompPositionalArgumentFile(1, string{"*.log", "*.txt"})
var filterFileCmd = &cobra.Command{
	Use:   "filterFile",
	Short: "Only list file of type [*.log,*.txt]",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		if len(args) == 0 {
			return []string{"log", "txt"}, cobra.ShellCompDirectiveFilterFileExt
		}
		// No more expected arguments, so turn off file completion
		return nil, cobra.ShellCompDirectiveNoFileComp
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("filterFile called")
	},
}

// Turn off file completion for all arguments
var noFileCmd = &cobra.Command{
	Use:   "nofile",
	Short: "No file completion done",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return nil, cobra.ShellCompDirectiveNoFileComp
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("nofile called")
	},
}

// Full file completion for arguments
var fullFileCmd = &cobra.Command{
	Use:   "fullFile [filename]",
	Short: "Full file completion",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("fullFile called")
	},
}

// Only allow directory name completion and only for the first argument
var dirOnlyCmd = &cobra.Command{
	Use:   "dirOnly [dirname]",
	Short: "Only list directories in completion",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		if len(args) == 0 {
			return nil, cobra.ShellCompDirectiveFilterDirs
		}
		// No more expected arguments, so turn off file completion
		return nil, cobra.ShellCompDirectiveNoFileComp
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("dirOnly called")
	},
}

// Only allow directory name from within a specified directory and only for the first argument
var subdirCmd = &cobra.Command{
	Use:   "subdir [sub-dirname]",
	Short: "Only list directories within themes/",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		if len(args) == 0 {
			return []string{"themes"}, cobra.ShellCompDirectiveFilterDirs | cobra.ShellCompDirectiveNoFileComp
		}
		// No more expected arguments, so turn off file completion
		return nil, cobra.ShellCompDirectiveNoFileComp
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("subdir called")
	},
}

// Test file completion when returning other completions
var compAndFileCmd = &cobra.Command{
	Use:   "compAndFile [sun|moon|<filename>]",
	Short: "Provide some completions and file completion when prefix does not match",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		if len(args) != 0 {
			return []string{"nginx", "thanos"}, cobra.ShellCompDirectiveNoFileComp
		}
		var completions []string
		for _, comp := range []string{"install", "uninstall"} {
			completions = append(completions, comp)
		}
		return completions, cobra.ShellCompDirectiveDefault
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("compAndFile called")
	},
}

var colonCmd = &cobra.Command{
	Use:       "cmdColonArgs",
	Short:     "Command with colon args",
	ValidArgs: []string{"first:ONE", "first:SECOND"},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("colonCmd called")
	},
}

var longDescCmd = &cobra.Command{
	Use:       "cmdLongDesc12345678901234567890123456789012345678901234567890",
	Short:     `We have here a quite long description which should go over the length of the shell width.  What should we do with such a long description? zsh and fish handle it nicely, so we should prepare bash to handle it in the same fashion`,
	ValidArgs: []string{"first:ONE", "first:SECOND"},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("colonCmd called")
	},
}

var specialCharDescCmd = &cobra.Command{
	Use:   "specialChar",
	Short: "Description contains chars like ` and maybe others",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("specialChar cmd called")
	},
}

var noSpaceCmd = &cobra.Command{
	Use:   "nospace",
	Short: "followed by completion with noSpace, even for file completion",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		comps := []string{"complete\tdescription1", "compost\tdescription2"}
		if len(args) == 0 {
			// Allow file completion with ShellCompDirectiveNoSpace
			return comps, cobra.ShellCompDirectiveNoSpace
		}

		var finalComps []string
		for _, comp := range comps {
			if strings.HasPrefix(comp, toComplete) {
				finalComps = append(finalComps, comp)
			}
		}
		return finalComps, cobra.ShellCompDirectiveNoSpace
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("nospace cmd called")
	},
}

var sentenceCmd = &cobra.Command{
	Use:   "sentence",
	Short: "completion has spaces",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		// Allow file completion with ShellCompDirectiveNoSpace
		return []string{"comp is a sentence\tFirst comp", "and another sentence\tsecondComp"}, cobra.ShellCompDirectiveNoFileComp
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("sentence cmd called")
	},
}

var withfileCmd = &cobra.Command{
	Use:   "withfile",
	Short: "completion always returned and has file completion",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		// We do not consider the toComplete prefix and always return a completion
		return []string{"why"}, cobra.ShellCompDirectiveDefault
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("withfile cmd called")
	},
}

var withflagsCmd = &cobra.Command{
	Use:   "withflags",
	Short: "command that has multiple flags",
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		// We do not consider the toComplete prefix and always return a completion
		return []string{"why", "who", "when", "where"}, cobra.ShellCompDirectiveDefault
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("withflags cmd called")
		fmt.Println("flagA is:", *flagA)
		fmt.Println("flagB is:", *flagB)
		fmt.Println("flagC is:", *flagC)
		fmt.Println("flagD is:", *flagD)
		fmt.Println("flagS is:", *flagS)
	},
}

func setFlags() {
	rootCmd.Flags().String("theme", "", "theme to use (located in /themes/THEMENAME/)")
	rootCmd.Flags().SetAnnotation("theme", cobra.BashCompSubdirsInDir, []string{"themes"})

	rootCmd.Flags().String("theme2", "", "theme to use (located in /themes/THEMENAME/)")
	rootCmd.RegisterFlagCompletionFunc("theme2", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"themes"}, cobra.ShellCompDirectiveFilterDirs
	})

	rootCmd.Flags().String("customComp", "", "test custom comp for flags")
	rootCmd.RegisterFlagCompletionFunc("customComp", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"firstComp\tthe first value", "secondComp\tthe second value", "forthComp\tthe forth value"}, cobra.ShellCompDirectiveNoFileComp
	})

	rootCmd.Flags().StringP("file", "f", "", "list files")
	rootCmd.Flags().String("longdesc", "", "before newline\nafter newline")

	rootCmd.Flags().BoolP("bool", "b", false, "bool flag")
	rootCmd.Flags().BoolSliceP("bslice", "B", nil, "bool slice flag")

	rootCmd.PersistentFlags().StringP("persistent", "p", "", "persistent flag")

	// rootCmd.Flags().String("required", "", "required flag")
	// rootCmd.MarkFlagRequired("required")

	vargsCmd.Flags().StringP("nonpersistent", "n", "", "non persistent local flag")

	// If there is only a recommended value before we reach the equal sign or the colon, then the completion works as expected.
	// If the values differ afterwards, completion fails in bash, but works in fish and zsh
	rootCmd.Flags().String("equalSignWorks", "", "test custom comp with equal sign")
	rootCmd.RegisterFlagCompletionFunc("equalSignWorks", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"first=Comp\tthe first value", "second=Comp\tthe second value", "forth=Comp\tthe forth value"}, cobra.ShellCompDirectiveNoFileComp
	})

	rootCmd.Flags().String("equalSignWorksNot", "", "test custom comp with equal sign")
	rootCmd.RegisterFlagCompletionFunc("equalSignWorksNot", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"first=Comp1\tthe first value", "first=Comp2\tthe second value", "first=Comp3\tthe forth value"}, cobra.ShellCompDirectiveNoFileComp
	})

	rootCmd.Flags().String("colonWorks", "", "test custom comp with colon one value works")
	rootCmd.RegisterFlagCompletionFunc("colonWorks", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"first:ONE\tthe first value", "second\tthe second value", "forth\tthe forth value"}, cobra.ShellCompDirectiveNoFileComp
	})

	rootCmd.Flags().String("colonWorksNot", "", "test custom comp with colon doesnt work")
	rootCmd.RegisterFlagCompletionFunc("colonWorksNot", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"first:ONE\tthe first value", "first:SECOND\tthe second value", "second:Comp1\tthe forth value"}, cobra.ShellCompDirectiveNoFileComp
	})

	rootCmd.Flags().String("nospace", "", "test custom comp with nospace directive")
	rootCmd.RegisterFlagCompletionFunc("nospace", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"complete\tFirst comp", "compost\tsecondComp"}, cobra.ShellCompDirectiveNoSpace
	})

	rootCmd.Flags().StringArray("array", []string{"allo", "toi"}, "string array flag")

	flagA = withflagsCmd.Flags().BoolP("boolA", "a", false, "bool flag 1")
	flagB = withflagsCmd.Flags().BoolP("boolB", "b", false, "bool flag 2")
	flagC = withflagsCmd.Flags().BoolP("boolC", "c", false, "bool flag 3")
	flagD = withflagsCmd.Flags().BoolP("boolD", "d", false, "bool flag 4")
	flagS = withflagsCmd.Flags().StringP("string", "s", "", "string flag")
	withflagsCmd.RegisterFlagCompletionFunc("string", func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		return []string{"complete\tFirst comp", "compost\tsecondComp"}, cobra.ShellCompDirectiveNoFileComp
	})
}

func main() {
	rootCmd.AddCommand(newCompletionCmd(os.Stdout))

	rootCmd.AddCommand(
		filterFileCmd,
		noFileCmd,
		fullFileCmd,
		dirOnlyCmd,
		subdirCmd,
		compAndFileCmd,
		nodescriptionCmd,
		vargsCmd,
		colonCmd,
		aliasCmd,
		longDescCmd,
		specialCharDescCmd,
		noSpaceCmd,
		sentenceCmd,
		withfileCmd,
		withflagsCmd,
	)

	vargsCmd.AddCommand(childVargsCmd)

	setFlags()

	rootCmd.Execute()

}
