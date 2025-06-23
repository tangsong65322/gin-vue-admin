# x-sqlite-s

## 简介
x-sqlite-s 是一个用于 uni-appx 的 SQLite 数据库操作插件，支持基本的数据库操作、加密、事务处理等功能。

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | x |

## 安装
在插件市场搜索并导入 x-sqlite-s 插件。

## 特别注意
配置中的密码等加密功能,未实现,只是一个预设功能.

## web注意事项

请到插件目录内复制static到你的根目录static即可。否则web无法使用。

## 类型定义

### SQLiteConfig 配置项
```typescript
type SQLiteConfig = {
    password?: string;      // 数据库密码
    encryption?: boolean;   // 是否启用加密
    defaultDirectory?: string; // 数据库文件存储目录
    locateFile?: (filename: string) => string;  // 自定义文件位置，web专用属性，默认内置
}
```

### SQLiteResult 返回结果
```typescript
type SQLiteResult = {
    rows?: any[][];        // 查询结果行数据
    columns?: string[];    // 列名
    maps?: any[];         // 查询结果对象数组，可通过列名访问数据
    changes?: number;      // 影响的行数
    lastInsertRowid?: number;  // 最后插入的行ID
    error?: string;        // 错误信息
}
```

### SQLiteExecuteBatchParams 批量执行参数
```typescript
type SQLiteExecuteBatchParams = {
    sql: string;           // SQL语句
    params?: any[];        // 参数列表
}
```

## API 说明

### 创建数据库
```javascript
createDb(filename?: string): boolean
// web端是Promise函数,执行时可以await createDb
// app是同步操作,不是Promise
```
创建或打开一个数据库。如果未指定文件名，默认为 "sqlite.db"。

### 执行SQL查询
```javascript
run(sql: string, params: any[] = []): SQLiteResult
```
执行一条SQL语句，支持参数绑定。

### 查询数据
```javascript
query(sql: string, params: any[] = []): SQLiteResult
```
执行查询语句并返回结果集。

### 插入数据
```javascript
insert(table: string, data: object): SQLiteResult
```
向指定表插入数据。

### 更新数据
```javascript
update(table: string, data: object, where: string, params: any[] = []): SQLiteResult
```
更新表中的数据。

### 删除数据
```javascript
delete(table: string, where: string, params: any[] = []): SQLiteResult
```
删除表中的数据。

### 事务处理
```javascript
beginTransaction(): SQLiteResult  // 开始事务
commit(): SQLiteResult           // 提交事务
rollback(): SQLiteResult         // 回滚事务
```

### 批量执行
```javascript
executeBatch(statements: SQLiteExecuteBatchParams[]): SQLiteResult[]
```
批量执行SQL语句，支持事务。

### 数据库文件管理

**createDb,loadFromBuffer,loadLocal三个函数**
**web端是Promise函数**
**app是同步操作,不是Promise**

```javascript
createDb(filename?: string): boolean    // 创建一个本地数据库,重命的重复创建不会覆盖,只是读取已有的数据库.
saveLocal(filename?: string): SQLiteResult    // 保存数据库到本地
loadLocal(filename: string): SQLiteResult     // 从本地加载数据库
getDatabasePath(): string | null             // app端获取数据库备份临时文件路径
getDatabasePath(): Uint8Array | null         // web端返回的是二进制数据
loadFromBuffer(buffer: Uint8Array):void      // web端专用函数,用来从进制制数据加载远程数据库
setDefaultDirectory(directory: string): void  // 设置数据库文件存储目录
setPassword(password: string|null): void      // 设置数据库密码，null或空值表示删除密码
```

### 表操作
```javascript
tableExists(tableName: string): boolean       // 检查表是否存在
createTable(tableName: string, columns: UTSJSONObject): SQLiteResult  // 创建表
dropTable(tableName: string): SQLiteResult    // 删除表
```

## 使用示例

### 基本操作
```javascript
import {xSqlite} from "@/uni_modules/x-sqlite-s"

// 创建数据库实例并配置
const db = new xSqlite({
    encryption: true,
    password: "mypassword",
    defaultDirectory: "/custom/db/path"
});

// 创建数据库
db.createDb("mydb");

// 创建表
db.createTable("users", {
    "id": "INTEGER PRIMARY KEY AUTOINCREMENT",
    "name": "TEXT",
    "age": "INTEGER"
});

// 插入数据
db.insert("users", {
    name: "张三",
    age: 25
});

// 查询数据
const result = db.query("SELECT * FROM users WHERE age > ?", [20]);
console.log(result.rows);    // 通过数组下标访问：[[1, "张三", 25], [2, "李四", 30]]
console.log(result.maps);    // 通过列名访问：[{"id": 1, "name": "张三", "age": 25}, {"id": 2, "name": "李四", "age": 30}]
```

### 事务使用
```javascript
// 开始事务
db.beginTransaction();

try {
    db.insert("users", { name: "李四", age: 30 });
    db.insert("users", { name: "王五", age: 35 });
    db.commit();
} catch (e) {
    db.rollback();
}
```

### 批量操作
```javascript
const statements = [
    {
        sql: "INSERT INTO users (name, age) VALUES (?, ?)",
        params: ["赵六", 40]
    },
    {
        sql: "UPDATE users SET age = ? WHERE name = ?",
        params: [45, "张三"]
    }
];

db.executeBatch(statements);
```

### 数据库配置管理
```javascript
// 更改数据库存储目录
db.setDefaultDirectory("/new/db/path");

// 更新数据库密码
db.setPassword("newpassword");

// 移除数据库密码
db.setPassword(null);
```

## 注意事项
1. 在进行数据库操作前，确保已经成功创建/打开数据库
2. 使用参数绑定来防止SQL注入
3. 大量数据操作时建议使用事务
4. 及时关闭不再使用的数据库连接
5. 加密数据库需要在创建时指定密码