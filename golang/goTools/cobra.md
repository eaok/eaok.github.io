

cobra既是一个用来创建的现代CLI命令行的golang库，也是一个生成程序应用和命令行文件的程序。



安装：

```bash
go get -v -u github.com/spf13/cobra/cobra
```



用命令初始化

```bash
cobra init --pkg-name cobra/demo demo
```

生成的目录如下：

```bash
├── demo
│   ├── LICENSE
│   ├── cmd
│   │   └── root.go
└── └── main.go
```

在demo目录下`cobra add login`，会自动生成login.go文件

```bash
.
├── LICENSE
├── cmd
│   ├── login.go
│   └── root.go
└── main.go
```



cobra 中的命令可以分成3部分，分别是 commands、命令行参数(arguments) 和 命令行选项(flags)。

```bash
# clone 是 commands，URL 是 arguments，brae 是 flag
git clone URL --bare
```



## 处理Flags

Persistent Flags
persistent意思是说这个flag能任何命令下均可使用，适合全局flag：

```go
RootCmd.PersistentFlags().BoolVarP(&Verbose, "verbose", "v", false, "verbose output")
```

Local Flags
Cobra同样支持局部标签(local flag)，并只在直接调用它时运行

```go
RootCmd.Flags().StringVarP(&Source, "source", "s", "", "Source directory to read from")
```

Bind flag with Config
使用viper可以绑定flag

```go
var author string

func init() {
  RootCmd.PersistentFlags().StringVar(&author, "author", "YOUR NAME", \
                                      "Author name for copyright attribution")
  viper.BindPFlag("author", RootCmd.PersistentFlags().Lookup("author"))
}
```



## 参数验证

### 默认的参数验证

cobra 默认提供了一些验证方法有以下几类：

- `NoArgs`: 如果包含任何位置参数，命令报错
- `ArbitraryArgs`: 命令接受任何参数
- `OnlyValidArgs`: 如果有位置参数不在`ValidArgs`中，命令报错
- `MinimumArgs(init)`: 如果参数数目少于N个后，命令行报错
- `MaximumArgs(init)`: 如果参数数目多余N个后，命令行报错
- `ExactArgs(init)`: 如果参数数目不是N个话，命令行报错
- `RangeArgs(min, max)`: 如果参数数目不在范围(min, max)中，命令行报错

### 自定义参数验证

```go
var cmd = &cobra.Command{
  Short: "hello",
  Args: func(cmd *cobra.Command, args []string) error {
    if len(args) < 1 {
      return errors.New("requires at least one arg")
    }
    if myapp.IsValidColor(args[0]) {
      return nil
    }
    return fmt.Errorf("invalid color specified: %s", args[0])
  },
  Run: func(cmd *cobra.Command, args []string) {
    fmt.Println("Hello, World!")
  },
}
```



### 自定义help和usage，智能提示

可以通过以下来自定义help:

```go
command.SetHelpCommand(cmd *Command)
command.SetHelpFunc(f func(*Command, []string))
command.SetHelpTemplate(s string)
```

可以通过以下来自定义usage:

```go
command.SetUsageFunc(f func(*Command) error)
command.SetUsageTemplate(s string)
```



如果你想关闭智能提示，可以：

```go
command.DisableSuggestions = true
// 或者
command.SuggestionsMinimumDistance = 1
```

或者使用`SuggestFor`属性来自定义一些建议



## Run功能的执行先后顺序如下：

- PersistentPreRun
- PreRun
- Run
- PostRun
- PersistentPostRun



```go
package main

import (
  "fmt"

  "github.com/spf13/cobra"
)

func main() {

  var rootCmd = &cobra.Command{
    Use:   "root [sub]",
    Short: "My root command",
    PersistentPreRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PersistentPreRun with args: %v\n", args)
    },
    PreRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PreRun with args: %v\n", args)
    },
    Run: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd Run with args: %v\n", args)
    },
    PostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PostRun with args: %v\n", args)
    },
    PersistentPostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside rootCmd PersistentPostRun with args: %v\n", args)
    },
  }

  var subCmd = &cobra.Command{
    Use:   "sub [no options!]",
    Short: "My subcommand",
    PreRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside subCmd PreRun with args: %v\n", args)
    },
    Run: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside subCmd Run with args: %v\n", args)
    },
    PostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside subCmd PostRun with args: %v\n", args)
    },
    PersistentPostRun: func(cmd *cobra.Command, args []string) {
      fmt.Printf("Inside subCmd PersistentPostRun with args: %v\n", args)
    },
  }

  rootCmd.AddCommand(subCmd)

  rootCmd.SetArgs([]string{""})
  rootCmd.Execute()
  fmt.Println()
  rootCmd.SetArgs([]string{"sub", "arg1", "arg2"})
  rootCmd.Execute()
}
```

Output:

```bash
Inside rootCmd PersistentPreRun with args: []
Inside rootCmd PreRun with args: []
Inside rootCmd Run with args: []
Inside rootCmd PostRun with args: []
Inside rootCmd PersistentPostRun with args: []

Inside rootCmd PersistentPreRun with args: [arg1 arg2]
Inside subCmd PreRun with args: [arg1 arg2]
Inside subCmd Run with args: [arg1 arg2]
Inside subCmd PostRun with args: [arg1 arg2]
Inside subCmd PersistentPostRun with args: [arg1 arg2]
```

## 错误处理函数

RunE功能的执行先后顺序如下：

- PersistentPreRunE
- PreRunE
- RunE
- PostRunE
- PersistentPostRunE