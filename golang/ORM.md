# ORM

Object-Relationl Mapping， 它的作用是映射数据库和对象之间的关系，方便我们在实现数据库操作的时候不用去写复杂的sql语句，把对数据库的操作上升到对于对象的操作。

ORM  ==> 对象/实例 与关系型数据库的映射

| 关系型数据库 | 对象/实例       |
| ------------ | --------------- |
| 数据表       | 类/结构体       |
| 数据行       | 对象/实例       |
| 数据字段     | 属性/结构体字段 |



## 一、beego中的ORM

## 二、GORM

**官方文档** http://gorm.io/zh_CN/docs/

**网上的文档** http://gorm.book.jasperxu.com/

**Github** https://github.com/jinzhu/gorm



重点内容：

- 别忘了导入驱动
- gorm.Model
- Model结构体支持的tag
- 字段默认值和空值
- 增删改查
- 钩子函数



### 创建DB连接

```go
package main

import (
    "github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
)

func main() {
	var err error
	db, connErr := gorm.Open("mysql", "root:rootroot@/dqm?charset=utf8&parseTime=True&loc=Local")
	if connErr != nil {
		panic("failed to connect database")
	}
	defer db.Close()
    db.SingularTable(true)
}
```

### 创建映射表结构的struct

文档中的位置：http://gorm.io/zh_CN/docs/models.html

比如这里我们要操作的是表test表，表结构如下

```sql
CREATE TABLE `test` (
  `id` bigint(20) NOT NULL,
  `name` varchar(5) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
```

对应可以定义struct结构如下

```go
type Test struct {
	ID   int64  `gorm:"type:bigint(20);column:id;primary_key"`
	Name string `gorm:"type:varchar(5);column:name"`
	Age  int    `gorm:"type:int(11);column:age"`
}
```

### CURD

增：

```go
test := &Test{
		ID:3,
		Name:"jackie",
		Age:18,
	}
db.Create(test)
```

删：

```go
test := &Test{
		ID:3,
		Name:"jackie",
		Age:18,
	}
db.Delete(test)
```

改：

```go
test := &Test{
		ID:   3,
		Name: "hello",
		Age:  18,
	}
db.Model(&test).Update("name", "world")
```

查：

```go
var testResult Test
db.Where("name = ?", "hello").First(&testResult)
fmt.Println("result: ", testResult)
```

### 表名和结构体的映射

gorm默认会在你定义的struct名后面加上”s“，可以通过如下三种方法设置

1. 设置db.SingularTable(true)

2. 实现TableName方法

   ```go
   func (Test) TableName() string {
   	return "test"
   }
   ```

3. 通过Table API声明

   ```go
   db.Table("test").Where("name = ?", "hello").First(&testResult)
   ```

   

## 三、XORM

