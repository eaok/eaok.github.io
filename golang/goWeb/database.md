[TOC]

# 一、database/sql

Go没有内置的驱动支持任何的数据库，但是Go定义了database/sql接口，用户可以基于驱动接口开发相应数据库的驱动。

## sql.Register

sql.Register是用来注册数据库驱动的，当第三⽅开发者开发数据库驱动时，都会实 现init函数，在init⾥⾯会调⽤这个 Register(name string, driver driver.Driver) 完成本驱动的注册。

mysql驱动的注册：

```go
import _ "github.com/go-sql-driver/mysql"
```

```go
func init() {
 	sql.Register("mysql", &MySQLDriver{})
}

type MySQLDriver struct{}

func (d MySQLDriver) Open(dsn string) (driver.Conn, error) {
 	...
}
```



## 相关的接口

### driver.Driver

```go
type Driver interface {
    Open(name string) (Conn, error)
}
```

`init()`通过`Register()`方法将mysql驱动添加到sql.drivers(类型：`make(map[string]driver.Driver)`)中，MySQLDriver实现了driver.Driver接口。Open返回的Conn只能用来进行一次goroutine的操作；



### driver.Conn

```go
type Conn interface {
    Prepare(query string) (Stmt, error)	//返回与当前连接相关的执行Sql语句的准备状态
    Close() error						//关闭当前的连接
    Begin() (Tx, error)					//返回一个代表事务处理的Tx
}
```



### driver.Stmt

```go
type Stmt interface {
    Close() error						//关闭当前的连接状态
    NumInput() int						//返回当前预留参数的个数
    Exec(args []Value) (Result, error)	//执行update/insert等操作，返回Result数据。
    Query(args []Value) (Rows, error)	//执行select操作，返回Rows结果集。
}
```



### driver.Tx

```go
type Tx interface {
    Commit() error		//递交事务
    Rollback() error	//回滚事务
}
```



### driver.Execer

```go
type Execer interface {
    Exec(query string, args []Value) (Result, error)
}
```

这是一个Conn可选择实现的接口，如果这个接口没有定义，那么在调用DB.Exec时，就会首先调用Prepare返回Stmt，然后执行Stmt的Exec，然后关闭Stmt。



### driver.Result

```go
type Result interface {
    LastInsertId() (int64, error)	//返回由数据库执行插入操作得到的自增ID号
    RowsAffected() (int64, error)	//返回query操作影响的数据条目数
}
```

这个是执行Update/Insert等操作返回的结果接口定义。



### driver.Rows

```go
type Rows interface {
    Columns() []string			//返回查询数据库表的字段信息
    Close() error				//关闭Rows迭代器
    Next(dest []Value) error	//返回下一条数据，如果最后没数据了，返回io.EOF
}
```

Rows是执行查询返回的结果集接口定义



### driver.Value

Value其实就是一个空接口，他可以容纳任何的数据。

```go
type Value interface{}
```

drive的Value是驱动必须能够操作的Value，Value要么是nil，要么是下面的任意一种

```go
int64
float64
bool
[]byte
string [*]除了Rows.Next返回的不能是string.
time.Time
```



### driver.ValueConverter

ValueConverter接口定义了如何把一个普通的值转化成driver.Value的接口

```go
type ValueConverter interface {

    ConvertValue(v interface{}) (Value, error)

}
```

在开发的数据库驱动包里面实现这个接口的函数在很多地方会使用到，这个ValueConverter有很多好处：

1. 转化`driver.value`到数据库表相应的字段，例如int64的数据如何转化成数据库表uint16字段
2. 把数据库查询结果转化成`driver.Value`值
3. 在scan函数里面如何把`driver.Value`值转化成用户定义的值



### driver.Valuer

```go
type Valuer interface {
    Value() (Value, error)
}
```

Valuer接口定义了返回一个`driver.Value`的方式，很多类型都实现了这个Value方法，用来自身与`driver.Value`的转化。



## DB结构体

database/sql在database/sql/driver提供的接口基础上定义了一些更高阶的方法，用以简化数据库操作,同时内部还建议性地实现一个conn pool。

```go
type DB struct {
    driver driver.Driver  //数据库实现驱动
    dsn    string  //数据库连接、配置参数信息，比如username、host、password等
    numClosed uint64

    mu           sync.Mutex          //锁，操作DB各成员时用到
    freeConn     []*driverConn       //空闲连接
    connRequests []chan connRequest  //阻塞请求队列，等连接数达到最大限制时，后续请求将插入此队列等待可用连接
    numOpen      int                 //已建立连接或等待建立连接数
    openerCh    chan struct{}        //用于connectionOpener
    closed      bool
    dep         map[finalCloser]depSet
    lastPut     map[*driverConn]string // stacktrace of last conn's put; debug only
    maxIdle     int                    //最大空闲连接数
    maxOpen     int                    //数据库最大连接数
    maxLifetime time.Duration          //连接最长存活期，超过这个时间连接将不再被复用
    cleanerCh   chan struct{}
}
```

> `maxIdle`(默认值2)、`maxOpen`(默认值0，无限制)、`maxLifetime(默认值0，永不过期)`可以分别通过`SetMaxIdleConns`、`SetMaxOpenConns`、`SetConnMaxLifetime`设定。

我们可以看到Open函数返回的是DB对象，里面有一个freeConn，它就是那个简易的连接池。它的实现相当简单或者说简陋，就是当执行Db.prepare的时候会`defer db.putConn(ci, err)`，也就是把这个连接放入连接池，每次调用conn的时候会先判断freeConn的长度是否大于0，大于0说明有可以复用的conn，直接拿出来用就是了，如果不大于0，则创建一个conn,然后再返回之。

> 这时mysql还没有建立连接，只是初始化了一个`sql.DB`结构，这是非常重要的一个结构，所有相关的数据都保存在此结构中；Open同时启动了一个`connectionOpener`协程。



## 连接与释放

获取连接

Open时是没有建立数据库连接的，只有等用的时候才会实际建立连接，获取可用连接的操作有两种策略：cachedOrNewConn(有可用空闲连接则优先使用，没有则创建)、alwaysNewConn(不管有没有空闲连接都重新创建)：

```go
rows, err := db.Query("select * from userinfo")
```



释放连接

a.Exec(update、insert、delete等无结果集返回的操作)调用完后会自动释放连接； b.Query(返回sql.Rows)则不会释放连接，调用完后仍然占有连接，它将连接的所属权转移给了sql.Rows，所以需要手动调用close归还连接，即使不用Rows也得调用rows.Close()；

```go
db.SetMaxOpenConns(1)
row, err := db.Query("select * from test")
row.Close() //将连接的所属权归还，释放连接
```





# 二、MYSQL数据库

## 1.安装与连接

docker安装：

```bash
docker pull mysql
docker run --name mysql -e MYSQL_ROOT_PASSWORD=root -dp 3306:3306 --restart=always mysql
docker exec -it mysql /bin/bash
mysql --default-character-set=utf8mb4 -uroot -proot
```



MySQL的驱动一般用的是`github.com/go-sql-driver/mysql`

```go
import (
    "database/sql"
	_ "github.com/go-sql-driver/mysql"
)
```

Open函数：

> ```go
> func Open(driverName, dataSourceName string) (*DB, error)
> ```
>
> `sql.Open`只是初始化一个sql.DB对象，当真正进行第一次数据库查询操作时才会真正建立网络连接；
>
> `sql.DB`的设计就是用来作为长连接使用的。不要频繁Open, Close。比较好的做法是，为每个不同的datastore建一个DB对象，保持这些对象Open。如果需要短连接，那么把DB作为参数传入function，而不要在function中Open, Close。



Go连接MySQL例子：

```go
func main() {
    db, err := sql.Open("mysql", "root:root@tcp(127.0.0.1:3306)/demo?charset=utf8mb4")
    if err != nil {
        fmt.Println("创建数据库对象db失败")
        return
    }
    defer db.Close()  // db对象创建成功之后才可能调用它的Close方法
    
    err = db.Ping()  // 真正尝试去连数据库
    if err != nil {
        fmt.Printf("连接数据库失败，err:%v\n", err)
        return
    }
    fmt.Println("连接数据库成功。。")
}
```



## 2.增删改查

### 2.1增删改

直接使用db.Exec函数添加：

```go
result, err := db.Exec("UPDATE userinfo SET username = ?, departname = ? WHERE uid = ?", "王一博","行政部",2)
```

先使用db.Prepare获得stmt，然后调用Exec方法添加：

```go
stmt,err:=db.Prepare("INSERT INTO userinfo(username,departname,created) values(?,?,?)") 
//补充完整sql语句，并执行
result,err:=stmt.Exec("杨超越","技术部","2019-11-21")
```

 **预编译语句(Prepared Statement)** 提供了诸多好处, 因此我们在开发中尽量使用它. 下面列出了使用预编译语句所提供的功能:

- PreparedStatement 可以实现自定义参数的查询

- PreparedStatement 通常比手动拼接字符串 SQL 语句高效

- PreparedStatement 可以防止SQL注入攻击

  

**处理结果**

获取影响数据库的行数，可以根据该数值判断是否插入或删除或修改成功。

```go
 count, err := result.RowsAffected()
```

获得刚刚添加数据的自增ID

```go
id, err := result.LastInsertId()
```



### 2.2查询

#### 查询一条

查询单条数据，使用QueryRow方法

```go
func (db *DB) QueryRow(query string, args ...interface{}) *Row
func (rs *Rows) Scan(dest ...interface{}) error
```

因为golang是强类型语言，所以查询数据时先定义数据类型，但是查询数据库中的数据存在三种可能:存在值，存在零值，未赋值NULL 三种状态, 因为可以将待查询的数据类型定义为`sql.Nullxxx`类型，可以通过判断Valid值来判断查询到的值是否为赋值状态还是未赋值NULL状态.

示例代码：

```go
var username, departname, created string
row := db.QueryRow("SELECT username,departname,created FROM userinfo WHERE uid=?", 3)
err := row.Scan(&username, &departname, &created)

//也可以简写：
err := db.QueryRow("SELECT username,departname,created FROM userinfo WHERE uid=?", 3).Scan(&username, &departname, &created)
```

#### 查询多条数据

使用Query()方法

```go
func (db *DB) Query(query string, args ...interface{}) (*Rows, error)
func (rs *Rows) Next() bool
```

示例代码：

```go
rows, err := db.Query("SELECT uid,username,departname,created FROM userinfo")
for rows.Next() {
    var uid int
    var username, departname, created string
    err = rows.Scan(&uid, &username, &departname, &created); 
}
```



## 3.事务

事务操作是通过三个方法实现：

- Begin()：开启事务
- Commit()：提交事务（执行sql)
- Rollback()：回滚



事务四大特性ACID：

* 原子性
* 一致性
* 隔离性
* 永久性



例子：

```go
    //开启事务
    tx, _ := db.Begin()
    //提供一组sql操作
    var aff1, aff2 int64 = 0, 0
    result1, _ := tx.Exec("UPDATE account SET money=3000 WHERE id=?", 1)
    result2, _ := tx.Exec("UPDATE account SET money=2000 WHERE id=?", 2)
    //fmt.Println(result2)
    if result1 != nil {
        aff1, _ = result1.RowsAffected()
    }
    if result2 != nil {
        aff2, _ = result2.RowsAffected();
    }
    fmt.Println(aff1)
    fmt.Println(aff2)

    if aff1 == 1 && aff2 == 1 {
        //提交事务
        tx.Commit()
        fmt.Println("操作成功。。")
    } else {
        //回滚
        tx.Rollback()
        fmt.Println("操作失败。。。回滚。。")
    }
```

由于事务是一个一直连接的状态，所以Tx对象必须绑定和控制单个连接。一个Tx会在整个生命周期中保存一个连接，然后在调用`commit()`或`Rollback()`的时候释放掉。



## 4.sqlx包

sqlx包是作为database/sql包的一个额外扩展包，在原有的database/sql加了很多扩展，如直接将查询的数据转为结构体

**处理类型（Handle Types)**

sqlx设计和database/sql使用方法是一样的。包含有4中主要的handle types： 

- sqlx.DB - 和sql.DB相似，表示数据库。 
- sqlx.Tx - 和sql.Tx相似，表示事物。 
- sqlx.Stmt - 和sql.Stmt相似，表示prepared statement。 
- sqlx.NamedStmt - 表示prepared statement（支持named parameters）

此外，sqlx还有两个cursor类型： 

- sqlx.Rows - 和sql.Rows类似，Queryx返回。 
- sqlx.Row - 和sql.Row类似，QueryRowx返回。

相比database/sql方法还多了新语法，也就是实现将获取的数据直接转换结构体实现。

- Get(dest interface{}, …) error 用于获取单个结果然后Scan
- Select(dest interface{}, …) error 用来获取结果切片



例如：

```go
package main

import (
	"fmt"

	_ "github.com/go-sql-driver/mysql" // init()
	"github.com/jmoiron/sqlx"          // database/sql的升级版
)

type User struct {
	Uid        int
	Username   string
	Departname string
	Created    string
}

func main() {
	db, err := sqlx.Open("mysql", "root:root@tcp(127.0.0.1:3306)/demo?charset=utf8mb4")
	if err != nil {
		fmt.Println("创建数据库对象db失败", err)
		return
	}
	defer db.Close() // db对象创建成功之后才可能调用它的Close方法
	err = db.Ping()  // 真正尝试去连数据库
	if err != nil {
		fmt.Printf("连接数据库失败，err:%v\n", err)
		return
	}
	fmt.Println("连接数据库成功。。")

	// sqlx查询所有
	var users []User
	err = db.Select(&users, "SELECT uid,username,departname,created FROM userinfo")
	if err != nil {
		fmt.Println("Select error", err)
	}
	fmt.Printf("this is Select res:%v\n", users)

	// sqlx查询单条
	var user User
	err1 := db.Get(&user, "SELECT uid,username,departname,created FROM userinfo where uid = ?", 9)
	if err1 != nil {
		fmt.Println("GET error :", err1)
	}
	fmt.Printf("this is GET res:%v", user)
}
```





# 三、REDIS数据库

## 1.安装与连接

redis是一个key-value存储系统，类似还有Memcached。它支持存储的value类型相对更多，包括字符串（strings）、哈希（hashes）、列表（lists）、集合（sets）、带范围查询的排序集合（sorted sets）、位图（bitmaps）、hyperloglogs、带半径查询和流的地理空间索引等数据结构（geospatial indexes）。

docker安装redis

```bash
docker run --name redis -dp 6379:6379 --restart=always redis
```

golang操作redis的客户端推荐用redigo

```go
import (
	"github.com/gomodule/redigo/redis"
)
```

Conn接口是与Redis协作的主要接口，可以使用`Dial`，`DialWithTimeout`或者`NewConn`函数来创建连接，当任务完成时，应用程序必须调用Close函数来完成操作。

```go
import (
	"fmt"

	"github.com/gomodule/redigo/redis"
)

func main() {
	conn, err := redis.Dial("tcp", "localhost:6379")
	if err != nil {
		fmt.Println("connect redis error :", err)
		return
	}
	defer conn.Close()
	fmt.Println("connect success ...")
}
```



## 2.命令操作

常用redis命令：http://doc.redisfans.com/

通过使用Conn接口中的do方法执行redis命令，Do函数会必要时将参数转化为二进制字符串；

go中发送与响应对应类型：

| Go Type         | Conversion                          |
| :-------------- | :---------------------------------- |
| []byte          | Sent as is                          |
| string          | Sent as is                          |
| int, int64      | strconv.FormatInt(v)                |
| float64         | strconv.FormatFloat(v, 'g', -1, 64) |
| bool            | true -> "1", false -> "0"           |
| nil             | ""                                  |
| all other types | fmt.Print(v)                        |

Redis 命令响应会用以下Go类型表示：

| Redis type    | Go type                                    |
| :------------ | :----------------------------------------- |
| error         | redis.Error                                |
| integer       | int64                                      |
| simple string | string                                     |
| bulk string   | []byte or nil if value not present.        |
| array         | []interface{} or nil if value not present. |

可以使用Go的类型断言或者reply辅助函数将返回的interface{}转换为对应类型。



### 2.1 String操作

set/get

```go
	_, err = conn.Do("SET", "name", "lianshi")
	if err != nil {
		fmt.Println("redis set error:", err)
	}
	name, err := redis.String(conn.Do("GET", "name"))
	if err != nil {
		fmt.Println("redis get error:", err)
	} else {
		fmt.Printf("Got name: %s \n", name)
	}
```

mset/mget

```go
	_, err = conn.Do("MSET", "name", "xiaoxiao", "age", 18)
	if err != nil {
		fmt.Println("redis mset error:", err)
	}
	res, err := redis.Strings(conn.Do("MGET", "name", "age"))
	if err != nil {
		fmt.Println("redis get error:", err)
	} else {
		resType := reflect.TypeOf(res)
		fmt.Printf("res type : %s \n", resType)
		fmt.Printf("MGET name: %s \n", res)
		fmt.Println(len(res))
	}
```



### 2.2 List操作

```go
	_, err = conn.Do("LPUSH", "list1", "ele1", "ele2", "ele3", "ele4")
	if err != nil {
		fmt.Println("redis mset error:", err)
	}
	//res, err := redis.String(conn.Do("LPOP", "list1"))//获取栈顶元素
	//res, err := redis.String(conn.Do("LINDEX", "list1", 3)) //获取指定位置的元素
	res, err = redis.Strings(conn.Do("LRANGE", "list1", 0, 3)) //获取指定下标范围的元素
	if err != nil {
		fmt.Println("redis POP error:", err)
	} else {
		resType := reflect.TypeOf(res)
		fmt.Printf("res type : %s \n", resType)
		fmt.Printf("res  : %s \n", res)
	}
```



### 2.3 Hash操作

```go
	_, err = conn.Do("HSET", "user", "name", "lianshi", "age", 18)
	if err != nil {
		fmt.Println("redis mset error:", err)
	}
	res0, err := redis.Int64(conn.Do("HGET", "user", "age"))
	if err != nil {
		fmt.Println("redis HGET error:", err)
	} else {
		resType := reflect.TypeOf(res0)
		fmt.Printf("res type : %s \n", resType)
		fmt.Printf("res  : %d \n", res0)
	}
```



### 2.4 Pipeline操作

管道操作可以理解为并发操作，并通过`Send()，Flush()，Receive()`三个方法实现。客户端可以使用send()方法一次性向服务器发送一个或多个命令，命令发送完毕时，使用flush()方法将缓冲区的命令输入一次性发送到服务器，客户端再使用`Receive()`方法依次按照先进先出的顺序读取所有命令操作结果。

```go
Send(commandName string, args ...interface{}) error
Flush() error
Receive() (reply interface{}, err error)
```

- Send：发送命令至缓冲区
- Flush：清空缓冲区，将命令一次性发送至服务器
- Recevie：依次读取服务器响应结果，当读取的命令未响应时，该操作会阻塞。

```go
	conn.Send("HSET", "user1", "name", "lianshi", "age", "30")
	conn.Send("HSET", "user1", "sex", "female")
	conn.Send("HGET", "user1", "age")
	conn.Flush()

	res1, err := conn.Receive()
	fmt.Printf("Receive res1:%v \n", res1)
	res2, err := conn.Receive()
	fmt.Printf("Receive res2:%v\n", res2)
	res3, err := conn.Receive()
	fmt.Printf("Receive res3:%s\n", res3)
```



## 3.发布/订阅

redis本身具有发布订阅的功能，其发布订阅功能通过命令`SUBSCRIBE(订阅)／PUBLISH(发布)`实现，并且发布订阅模式可以是多对多模式还可支持正则表达式，发布者可以向一个或多个频道发送消息，订阅者可订阅一个或者多个频道接受消息。

```go
package main

import (
	"fmt"
	"time"

	"github.com/gomodule/redigo/redis"
)

func Subs() { // 订阅者
	conn, err := redis.Dial("tcp", "127.0.0.1:6379")
	if err != nil {
		fmt.Println("connect redis error :", err)
		return
	}
	defer conn.Close()

	psc := redis.PubSubConn{conn}
	psc.Subscribe("xxxxx") // 订阅channel1频道
	for {
		switch v := psc.Receive().(type) {
		case redis.Message:
			fmt.Printf("%s: message: %s\n", v.Channel, v.Data)
		case redis.Subscription:
			fmt.Printf("%s: %s %d\n", v.Channel, v.Kind, v.Count)
		case error:
			fmt.Println(v)
			return
		}
	}
}

func Push(message string) { //发布者
	conn, err := redis.Dial("tcp", "127.0.0.1:6379")
	if err != nil {
		fmt.Println("connect redis error :", err)
		return
	}
	defer conn.Close()

	_, err1 := conn.Do("PUBLISH", "xxxxx", message)
	if err1 != nil {
		fmt.Println("pub err: ", err1)
		return
	}
}

func main() {
	go Subs()
	go Push("this is lianshi")
	time.Sleep(time.Second * 5)
}
```





## 4.事务操作

`MULTI, EXEC,DISCARD,WATCH`是构成Redis事务的基础，当然我们使用go语言对redis进行事务操作的时候本质也是使用这些命令。

- `MULTI`：开启事务
- `EXEC` ：执行事务
- `DISCARD`：取消事务
- `WATCH`：监视事务中的键变化，可以监控一个或多个键，一旦有改变则取消事务。



MULTI操作：

```go
	//MULTI
	conn.Send("MULTI")
	conn.Send("INCR", "foo")
	conn.Send("INCR", "bar")
	reply, err := conn.Do("EXEC")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(reply)
```

watch操作：

```go
	// WATCH
	conn.Do("SET", "xxoo", 10)
	conn.Do("WATCH", "xxoo")
	v, _ := redis.Int64(conn.Do("GET", "xxoo"))
	v = v + 1 // 这里可以基于值做一些判断逻辑
	conn.Do("SET", "xxoo", 100)
	conn.Send("MULTI")
	conn.Send("SET", "xxoo", v)
	r, err := conn.Do("EXEC")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(r)
```

**注意事项**

- 由于WATCH命令的作用只是当被监控的键值被修改后阻止之后一个事务的执行，而不能保证其他客户端不修改这一键值，所以在一般的情况下我们需要在EXEC执行失败后重新执行整个函数。
- 执行EXEC命令后会取消对所有键的监控，如果不想执行事务中的命令也可以使用`UNWATCH`命令来取消监控。



## 5.连接池的使用

redis连接池是通过pool结构体实现，以下是源码定义，相关参数说明已经备注：

```go
type Pool struct {
    Dial func() (Conn, error) //连接方法
    TestOnBorrow func(c Conn, t time.Time) error

    //最大的空闲连接数，即使没有redis连接时依然可以保持N个空闲的连接，而不被清除，随时处于待命状态
    MaxIdle int  
    MaxActive int //最大的激活连接数，同时最多有N个连接
    IdleTimeout time.Duration  //空闲连接等待时间，超过此时间后，空闲连接将被关闭

    Wait bool  //当配置项为true并且MaxActive参数有限制时候，使用Get方法等待一个连接返回给连接池

    // Close connections older than this duration. If the value is zero, then
    // the pool does not close connections based on age.
    MaxConnLifetime time.Duration
}
```

例子：

```go
package main

import (
	"fmt"
	"time"

	"github.com/gomodule/redigo/redis"
)

var Pool redis.Pool

func init() { // init 用于初始化一些参数，先于main执行
	Pool = redis.Pool{
		MaxIdle:     16,
		MaxActive:   32,
		IdleTimeout: 120 * time.Second,
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial("tcp", "127.0.0.1:6379",
				redis.DialConnectTimeout(30*time.Millisecond),
				redis.DialReadTimeout(5*time.Millisecond),
				redis.DialWriteTimeout(5*time.Millisecond))
			if err != nil {
				fmt.Println(err)
				return nil, err
			}

			// auth认证
			//if _, err := c.Do("AUTH", "password"); err != nil {
			//	c.Close()
			//	return nil, err
			//}

			// 使用select指令选择数据库
			if _, err := c.Do("SELECT", 0); err != nil {
				c.Close()
				return nil, err
			}
			return c, nil
		},

		// 从连接池取出连接时要做的事
		TestOnBorrow: func(c redis.Conn, t time.Time) error {
			// t 当前连接被放回pool的时间
			if time.Since(t) < time.Minute { // 当该连接放回池子不到一分钟
				return nil
			}
			_, err := c.Do("PING") // 放回池子超过一分钟的连接需要执行PING操作
			return err
		},
	}
}

func someFunc() {
	conn := Pool.Get() // 从池子中取出一个连接
	defer conn.Close() // 把连接放回池子

	res, err := conn.Do("HSET", "user2", "name", "lianshi")
	fmt.Println(res, err)
	res1, err := redis.String(conn.Do("HGET", "user2", "name"))
	fmt.Printf("res:%s,error:%v\n", res1, err)
}

func main() {
	someFunc()
}
```



## 6.redis集群

`codis`   `redis-cluster`

连接哨兵或者集群模式的Redis推荐使用`https://github.com/go-redis/redis`

### 连接哨兵模式

```go
// See http://redis.io/topics/sentinel for instructions how to
// setup Redis Sentinel.
rdb := redis.NewFailoverClient(&redis.FailoverOptions{
    MasterName:    "master",
    SentinelAddrs: []string{"12.11.10.1:26379", "12.11.10.2:26379", "12.11.10.3:26379"},
})
rdb.Ping()
```



### 连接集群模式

16384个插槽（slot）

```go
// See http://redis.io/topics/cluster-tutorial for instructions
// how to setup Redis Cluster.
rdb := redis.NewClusterClient(&redis.ClusterOptions{
    Addrs: []string{":7000", ":7001", ":7002", ":7003", ":7004", ":7005"},
})
rdb.Ping()
```





**redis场景**

也是一个应用类工具，一定想办法把它用起来。。。

ZSET:榜单、排行榜、定时任务

INCR点赞

LIST 管理后台发通知邮件/短信 

去重

缓存 --> 把热点数据缓存起来，缩短响应时间





SQL注入

- 原理
- 如何避免

MySQL事务的隔离级别（面试会问）

MySQL优化 ***

- SQL语句层面优化 > 数据表的优化 > 数据库配置优化