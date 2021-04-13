[toc]

# 0x00 Protubuf简介

Google Protocol Buffer( 简称 Protobuf)是Google公司内部的混合语言数据标准，他们主要用于RPC系统和持续数据存储系统。Protobuf以高效的二进制方式存储，比XML小3到10倍，快20到100倍。



Protobuf3 语法指南：https://colobu.com/2017/03/16/Protobuf3-language-guide



# 0x01 安装protobuf编译器

linux下安装protobuf

下载二进制文件安装：https://github.com/protocolbuffers/protobuf/releases

```bash
wget ....zip
sudo unzip protoc-3.10.0-rc-1-linux-x86_64.zip -d /usr/local/
```

安装go插件 protoc-gen-go

```bash
go get -u github.com/golang/protobuf/protoc-gen-go
```



win安装protobuf

下载地址: https://github.com/google/protobuf/releases
下载win版本后，配置文件中的bin目录到Path环境变量下即可。



测试：

```
protoc --version #查看protoc的版本
```





# 0x02 使用protubuf

## 例子

创建protu文件：

```protobuf
syntax = "proto3";

package person;

message Person {
    string Name = 1;
    int32 Age = 2;
    string From = 3;
}
```

编译生成代码文件：

```bash
protoc --proto_path=. --go_out=. proto/person/person.proto
```

生成的`person.pb.go`中的结构体：

```go
type Person struct {
    Name                 string   `protobuf:"bytes,1,opt,name=Name,proto3" json:"Name,omitempty"`
    Age                  int32    `protobuf:"varint,2,opt,name=Age,proto3" json:"Age,omitempty"`
    From                 string   `protobuf:"bytes,3,opt,name=From,proto3" json:"From,omitempty"`
    XXX_NoUnkeyedLiteral struct{} `json:"-"`
    XXX_unrecognized     []byte   `json:"-"`
    XXX_sizecache        int32    `json:"-"`
}
```



在代码中使用：

```go
import (
    "fmt"
    "protobuf/proto/person"

    "github.com/golang/protobuf/proto"
)

func main() {
    p := &person.Person{
        Name: "Jack",
        Age:  10,
        From: "China",
    }
    fmt.Println("原始数据:", p)

    // 序列化
    dataMarshal, err := proto.Marshal(p)
    if err != nil {
        fmt.Println("proto.Unmarshal.Err: ", err)
        return
    }
    fmt.Println("编码数据:", dataMarshal)

    // 反序列化
    entity := person.Person{}
    err = proto.Unmarshal(dataMarshal, &entity)
    if err != nil {
        fmt.Println("proto.Unmarshal.Err: ", err)
        return
    }

    fmt.Printf("解码数据: 姓名：%s 年龄：%d 国籍：%s\n",
        entity.GetName(), entity.GetAge(), entity.GetFrom())
}
```



## 语法

### 修饰前缀

optional：表示该字段可以是0或1个，后面可加default默认值，如果不加则使用默认值
repeated：表示该字段可以是0到多个，packed=true 代表使用高效编码格式
注意：
id在1-15之间编码只需要占一个字节，包括Filed数据类型和Filed对应数字id
id在16-2047之间编码需要占两个字节，所以最常用的数据对应id要尽量小一些

使用required规则的时候要谨慎，因为以后结构若发生更改，这个Filed若被删除的话将可能导致兼容性的问题。

### 默认值

strings：默认是一个空string
bytes：默认是一个空的bytes
bools：默认是false
数值类型：默认是0

### 保留字段与id

每个字段对应唯一的数字id，但是如果该结构在之后的版本中某个Filed删除了，为了保持向前兼容性，需要将一些id或名称设置为保留，即不能被用来定义新的Field。

```go
message Person {
	reserved 2, 15, 9 to 11;
	reserved "samples", "email";
}
```



### 枚举类型

比如电话号码，只有移动电话、家庭电话、工作电话三种，因此枚举作为选项，如果没设置的话枚举类型的默认值为第一项。如果枚举类型中有不同的名字对应相同的数字id，需要加入option allow_alias = true这一项，否则会报错。枚举类型中也有reserverd Filed和number，定义和message中一样。

```go
message Person {
    required string name = 1;
    required int32 id = 2;
    optional string email = 3;
    enum PhoneType {
        MOBILE = 0;
        HOME = 1;
        WORK = 2;
	}
	message PhoneNumber {
	    required string number = 1;
	    optional PhoneType type = 2 [default = HOME];
	}
	repeated PhoneNumber phones = 4;
}
```

### 引用其他message类

在同一个文件中，可以直接引用定义过的message类型，在同一个项目中，可以用import来导入其它message类型。

```go
import "myproject/other_protos.proto";
```

### 双向流式RPC

双方使用读写流去发送一个消息序列。两个流独立操作，因此客户端和服务器可以以任意喜欢的顺序读写：比如， 服务器可以在写入响应前等待接收所有的客户端消息，或者可以交替的读取和写入消息，或者其他读写的组合。每个流中的消息顺序被预留。你可以通过在请求和响应前加  stream 关键字去制定方法的类型。



## 数据类型

| .proto类型 | java类型   | C++类型 | 备注                                                         |
| ---------- | ---------- | ------- | ------------------------------------------------------------ |
| double     | double     | double  |                                                              |
| float      | float      | float   |                                                              |
| int32      | int32      | int32   | 使用可变长编码方式。编码负数时不够高效——如果你的字段可能含有负数，那么请使用sint32。 |
| int64      | long       | int64   | 使用可变长编码方式。编码负数时不够高效——如果你的字段可能含有负数，那么请使用sint64。 |
| uint32     | int[1]     | uint32  | Uses variable-length encoding.                               |
| uint64     | long[1]    | uint64  | Uses variable-length encoding.                               |
| sint32     | int        | int32   | 使用可变长编码方式。有符号的整型值。编码时比通常的int32高效。 |
| sint64     | long       | int64   | 使用可变长编码方式。有符号的整型值。编码时比通常的int64高效。 |
| fixed32    | int[1]     | uint32  | 总是4个字节。如果数值总是比总是比228大的话，这个类型会比uint32高效。 |
| fixed64    | long[1]    | uint64  | 总是8个字节。如果数值总是比总是比256大的话，这个类型会比uint64高效。 |
| sfixed32   | int        | int32   | 总是4个字节                                                  |
| sfixed64   | long       | int64   | 总是8个字节                                                  |
| bool       | boolean    | bool    |                                                              |
| string     | string     | string  | 一个字符串必须是UTF-8编码或者7-bit ASCII编码的文本。         |
| bytes      | ByteString | string  | 可能包含任意顺序的字节数据。                                 |

