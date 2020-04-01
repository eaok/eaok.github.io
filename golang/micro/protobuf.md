





[toc]

# 0x00 Protubuf简介

Google Protocol Buffer( 简称 Protobuf)是Google公司内部的混合语言数据标准，他们主要用于RPC系统和持续数据存储系统。Protobuf以高效的二进制方式存储，比XML小3到10倍，快20到100倍。



Protobuf3 语法指南：https://colobu.com/2017/03/16/Protobuf3-language-guide



# 0x01 安装protobuf编译器

下载二进制文件安装：https://github.com/protocolbuffers/protobuf/releases

```bash
wget ....zip
sudo unzip protoc-3.10.0-rc-1-linux-x86_64.zip -d /usr/local/
```

安装go插件 protoc-gen-go

```bash
go get -u github.com/golang/protobuf/protoc-gen-go
```



# 0x02 使用protubuf

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