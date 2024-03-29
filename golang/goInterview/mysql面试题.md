# mysql相关

1. [MySQL 索引使⽤有哪些注意事项呢？](#MySQL 索引使⽤有哪些注意事项呢？)
2. [MySQL 遇到过死锁问题吗，你是如何解决的？](#MySQL 遇到过死锁问题吗，你是如何解决的？)
3. [⽇常⼯作中你是怎么优化SQL的？](#⽇常⼯作中你是怎么优化SQL的？)



### MySQL 索引使⽤有哪些注意事项呢？

可以从三个维度回答这个问题：索引哪些情况会失效，索引不适合哪些场景，索引规则

索引哪些情况会失效

* 查询条件包含or，可能导致索引失效
* 如何字段类型是字符串，where时⼀定⽤引号括起来，否则索引失效
* like通配符可能导致索引失效。
* 联合索引，查询时的条件列不是联合索引中的第⼀个列，索引失效。
* 在索引列上使⽤mysql的内置函数，索引失效。
* 对索引列运算（如，+、-、*、/），索引失效。
* 索引字段上使⽤（！= 或者 < >，not in）时，可能会导致索引失效。
* 索引字段上使⽤is null， is not null，可能导致索引失效。
* 左连接查询或者右连接查询查询关联的字段编码格式不⼀样，可能导致索引失效。
* mysql估计使⽤全表扫描要⽐使⽤索引快,则不使⽤索引。

索引不适合哪些场景

* 数据量少的不适合加索引
* 更新⽐较频繁的也不适合加索引
* 区分度低的字段不适合加索引（如性别）

索引的⼀些潜规则

* 覆盖索引
* 回表
* 索引数据结构（B+树）
* 最左前缀原则
* 索引下推



### MySQL 遇到过死锁问题吗，你是如何解决的？

我排查死锁的⼀般步骤是酱紫的：

1. 查看死锁⽇志show engine innodb status;
2. 找出死锁Sql
3. 分析sql加锁情况
4. 模拟死锁案发
5. 分析死锁⽇志
6. 分析死锁结果



### ⽇常⼯作中你是怎么优化SQL的？

可以从这⼏个维度回答这个问题：
 加索引
 避免返回不必要的数据
 适当分批量进⾏
 优化sql结构
 分库分表
 读写分离

