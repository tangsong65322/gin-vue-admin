package uts.sdk.modules.utsXsqliteS

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import org.json.JSONObject
import java.io.File
import io.dcloud.uts.console 

data class SQLiteConfigByKt(
    var password: String? = null,
    var encryption: Boolean = false,
    var locateFile: ((String) -> String)? = null,
    var defaultDirectory: String? = null
)

data class SQLiteResultByKt(
    val rows: List<List<Any>>? = null,
    val columns: List<String>? = null,
    val changes: Int? = null,
    val lastInsertRowid: Long? = null,
    val error: String? = null,
    val maps: List<Map<String, Any>>? = null
)

data class SQLiteExecuteBatchParamsByKt(
    val sql: String,
    val params: List<Any>? = null
)

class xSqliteHelp(private val context: Context, private val config: SQLiteConfigByKt = SQLiteConfigByKt()) {
    private var db: SQLiteDatabase? = null
    private var isInTransaction: Boolean = false
    private var fileURLPath: String? = null

    fun createDb(filename: String? = null): SQLiteDatabase? {
        val fname = filename ?: "sqlite"
        val dbFile = if (config.defaultDirectory != null) {
            File(config.defaultDirectory, "$fname.db")
        } else {
            context.getDatabasePath("$fname.db")
        }
		
        try {
            if (!dbFile.parentFile?.exists()!!) {
                dbFile.parentFile?.mkdirs()
            }

            db = SQLiteDatabase.openOrCreateDatabase(dbFile, null)
            if (config.encryption && config.password != null) {
                run("PRAGMA key = ?", listOf(config.password!!))
            }
            fileURLPath = dbFile.absolutePath
            return db
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }
	

    // 执行SQL查询
    fun run(sql: String, params: List<Any> = emptyList()): SQLiteResultByKt {
        return try {
            if (db == null) throw Exception("Database not initialized")
            val statement = db!!.compileStatement(sql)
            params.forEachIndexed { index, param ->
                when (param) {
                    is String -> statement.bindString(index + 1, param)
                    is Int -> statement.bindLong(index + 1, param.toLong())
                    is Long -> statement.bindLong(index + 1, param)
                    is Double -> statement.bindDouble(index + 1, param)
                    is ByteArray -> statement.bindBlob(index + 1, param)
                    null -> statement.bindNull(index + 1)
                }
            }
            
            // 根据SQL语句类型选择合适的执行方法
            val sqlUpperCase = sql.trim().uppercase()
            val result = if (sqlUpperCase.startsWith("INSERT")) {
                // 对于INSERT语句，使用executeInsert获取lastInsertRowid
                val lastId = statement.executeInsert()
                SQLiteResultByKt(changes = 1, lastInsertRowid = lastId)
            } else {
                // 对于UPDATE/DELETE/其他语句，使用executeUpdateDelete获取受影响的行数
                val changes = statement.executeUpdateDelete()
                SQLiteResultByKt(changes = changes, lastInsertRowid = null)
            }
            
            result
        } catch (e: Exception) {
            SQLiteResultByKt(error = e.message)
        }
    }
    

    // 查询数据
    fun query(sql: String, params: List<Any> = emptyList()): SQLiteResultByKt {
        return try {
            if (db == null) throw Exception("Database not initialized")
			val args = params.map { it?.toString() ?: "" }.toTypedArray()
            val cursor = db!!.rawQuery(sql, args)
            val columns = ArrayList(cursor.columnNames.toList())
            val rows = mutableListOf<List<Any>>()
            val maps = mutableListOf<Map<String, Any>>()
            
            while (cursor.moveToNext()) {
                val row = mutableListOf<Any>()
                val map = mutableMapOf<String, Any>()
                for (i in 0 until cursor.columnCount) {
                    val columnName = cursor.getColumnName(i)
                    val value = when (cursor.getType(i)) {
                        android.database.Cursor.FIELD_TYPE_STRING -> cursor.getString(i)
                        android.database.Cursor.FIELD_TYPE_INTEGER -> cursor.getLong(i)
                        android.database.Cursor.FIELD_TYPE_FLOAT -> cursor.getDouble(i)
                        android.database.Cursor.FIELD_TYPE_BLOB -> cursor.getBlob(i)
                        else -> ""
                    }
                    row.add(value)
                    map[columnName] = value
                }
                rows.add(row)
                maps.add(map)
            }
            cursor.close()
            SQLiteResultByKt(rows = rows, columns = columns, maps = maps)
        } catch (e: Exception) {
            SQLiteResultByKt(error = e.message)
        }
    }

    // 插入数据
    fun insert(table: String, data: JSONObject): SQLiteResultByKt {
        val keys = mutableListOf<String>()
        val values = mutableListOf<Any>()
        data.keys().forEach { key ->
            keys.add(key)
            values.add(data.get(key))
        }
        val sql = "INSERT INTO $table (${keys.joinToString(",")}) VALUES (${keys.map { "?" }.joinToString(",")})"  
        return run(sql, values)
    }

    // 更新数据
    fun update(table: String, data: JSONObject, where: String, params: List<Any> = emptyList()): SQLiteResultByKt {
        val sets = mutableListOf<String>()
        val values = mutableListOf<Any>()
        data.keys().forEach { key ->
            sets.add("$key = ?")
            values.add(data.get(key))
        }
        values.addAll(params)
        val sql = "UPDATE $table SET ${sets.joinToString(",")} WHERE $where"
        return run(sql, values)
    }

    // 删除数据
    fun delete(table: String, where: String, params: List<Any> = emptyList()): SQLiteResultByKt {
        val sql = "DELETE FROM $table WHERE $where"
        return run(sql, params)
    }

    // 保存数据库到本地
    fun saveLocal(filename: String? = null): SQLiteResultByKt {
        return try {
            if (db == null) throw Exception("Database not initialized")
            val fname = filename ?: "sqlite"
            
            // 获取当前数据库文件的实际路径
            val dbPath = db!!.path
            val dbFile = if (dbPath.isNotEmpty()) File(dbPath) else context.getDatabasePath("sqlite.db")
            // 检查源文件是否存在
            if (!dbFile.exists()) {
                return SQLiteResultByKt(error = "未能找到数据库文件")
            }
            
            // 使用配置的默认目录或系统文件目录
            val targetDir = if (config.defaultDirectory != null) File(config.defaultDirectory) else context.filesDir
            val targetFile = File(targetDir, "$fname.db")
			// 确保目标目录存在
			targetFile.parentFile?.mkdirs()
			if(dbFile.absolutePath != targetFile.absolutePath){
				dbFile.copyTo(targetFile, overwrite = true)
			}
          
            SQLiteResultByKt()
        } catch (e: Exception) {
            SQLiteResultByKt(error = e.message)
        }
    }

    // 从本地加载数据库
    fun loadLocal(filename: String): SQLiteResultByKt {
        return try {
            // 使用配置的默认目录或系统文件目录
            val sourceDir = if (config.defaultDirectory != null) File(config.defaultDirectory!!) else context.filesDir
            val sourceFile = File(sourceDir, "$filename.db")
            
            if (!sourceFile.exists()) {
                return SQLiteResultByKt(error = "没有数据库")
            }
            val dbFile = context.getDatabasePath("sqlite.db")
            sourceFile.copyTo(dbFile, overwrite = true)
            createDb(filename)
            SQLiteResultByKt()
        } catch (e: Exception) {
            SQLiteResultByKt(error = "数据库损坏")
        }
    }

    // 设置默认目录
    fun setDefaultDirectory(directory: String) {
        config.defaultDirectory = directory
    }

    // 设置密码
    fun setPassword(password: String?) {
        config.password = password
        config.encryption = password != null && password.isNotEmpty()
        
        if (db != null) {
            if (config.encryption && config.password != null) {
                run("PRAGMA rekey = ?", listOf(config.password!!))
            } else {
                run("PRAGMA rekey = ''", emptyList())
            }
        }
    }

    // 检查表是否存在
    fun tableExists(tableName: String): Boolean {
        val result = query("SELECT name FROM sqlite_master WHERE type='table' AND name=?", listOf(tableName))
        return result.rows?.isNotEmpty() == true
    }

    // 创建数据表
    fun createTable(tableName: String, columns: Map<String, String>): SQLiteResultByKt {
        val columnDefinitions = columns.entries.joinToString(",") { (name, type) -> "$name $type" }
        val sql = "CREATE TABLE IF NOT EXISTS $tableName ($columnDefinitions)"
        return run(sql)
    }

    // 删除数据表
    fun dropTable(tableName: String): SQLiteResultByKt {
        val sql = "DROP TABLE IF EXISTS $tableName"
        return run(sql)
    }

    // 关闭数据库
    fun close() {
        db?.close()
        db = null
    }

    // 开始事务
    fun beginTransaction(): SQLiteResultByKt {
        return try {
            if (isInTransaction) {
                return SQLiteResultByKt(error = "Transaction already in progress")
            }
            db?.beginTransaction()
            isInTransaction = true
            SQLiteResultByKt()
        } catch (e: Exception) {
            SQLiteResultByKt(error = e.message)
        }
    }

    // 提交事务
    fun commit(): SQLiteResultByKt {
        return try {
            if (!isInTransaction) {
                return SQLiteResultByKt(error = "No transaction in progress")
            }
            db?.setTransactionSuccessful()
            db?.endTransaction()
            isInTransaction = false
            SQLiteResultByKt()
        } catch (e: Exception) {
            SQLiteResultByKt(error = e.message)
        }
    }

    // 回滚事务
    fun rollback(): SQLiteResultByKt {
        return try {
            if (!isInTransaction) {
                return SQLiteResultByKt(error = "No transaction in progress")
            }
            db?.endTransaction()
            isInTransaction = false
            SQLiteResultByKt()
        } catch (e: Exception) {
            SQLiteResultByKt(error = e.message)
        }
    }

    // 批量执行SQL
    fun executeBatch(statements: List<SQLiteExecuteBatchParamsByKt>): List<SQLiteResultByKt> {
        val results = mutableListOf<SQLiteResultByKt>()
        var hasError = false

        val wasInTransaction = isInTransaction
        if (!wasInTransaction) {
            beginTransaction()
        }

        try {
            for (stmt in statements) {
                val result = run(stmt.sql, stmt.params ?: emptyList())
                results.add(result)
                if (result.error != null) {
                    hasError = true
                    break
                }
            }

            if (hasError && !wasInTransaction) {
                rollback()
            } else if (!wasInTransaction) {
                commit()
            }
        } catch (e: Exception) {
            if (!wasInTransaction) {
                rollback()
            }
            results.add(SQLiteResultByKt(error = e.message))
        }

        return results
    }

    /**
	 * 获取数据库文件路径获取前会备份到缓存目录
	 */
    fun getDatabasePath(): String? {
        if (db == null) return null
        
        try {
            // 获取当前数据库文件
            // val dbFile = db!!.path
			val dbFile = File(db!!.path)
            if (!dbFile.exists() || !dbFile.canRead()) {
                return null
            }
            
            // 获取缓存目录
            val cacheDir = context.cacheDir
            val tempFile = File(cacheDir, "tmui4x_xSqlite_DbackTemp.db")
            
            // 如果临时文件存在则删除
            if (tempFile.exists()) {
                tempFile.delete()
            }
            
            // 复制数据库文件到缓存目录
            dbFile.copyTo(tempFile, overwrite = true)
            
            return tempFile.absolutePath
        } catch (e: Exception) {
            return null
        }
    }
}