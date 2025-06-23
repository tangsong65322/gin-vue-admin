import Foundation
import SQLite3
// UTS内置对象的引用
import DCloudUTSFoundation

struct SQLiteConfigBySt {
    var password: String?
    var encryption: Bool
    var locateFile: ((String) -> String)?
    var defaultDirectory: String?
    
    init(password: String? = nil, encryption: Bool = false, locateFile: ((String) -> String)? = nil, defaultDirectory: String? = nil) {
        self.password = password
        self.encryption = encryption
        self.locateFile = locateFile
        self.defaultDirectory = defaultDirectory
    }
}

struct SQLiteResultBySt {
    var rows: [[Any]]?
    var columns: [String]?
    var changes: Int?
    var lastInsertRowid: Int64?
    var error: String?
    var maps: [[String: Any]]?
}

struct SQLiteExecuteBatchParamsBySt {
    var sql: String
    var params: [Any]?
}

class xSqliteHelp {
    private var db: OpaquePointer?
    private var isInTransaction: Bool = false
    private var config: SQLiteConfigBySt
    private var fileURLPath: URL?
    init(config: SQLiteConfigBySt = SQLiteConfigBySt()) {
        self.config = config
    }
    
    
    
    // 创建数据库
    func createDb(filename: String? = nil) -> OpaquePointer? {
        let fname = filename ?? "sqlite"
		let fileURL: URL
		if let defaultDir = config.defaultDirectory {
			fileURL = URL(fileURLWithPath: defaultDir).appendingPathComponent("\(fname).db")
			// 检查目录是否存在，不存在则递归创建
			let dirURL = fileURL.deletingLastPathComponent()
			let fileManager = FileManager.default
			if !fileManager.fileExists(atPath: dirURL.path) {
				do {
					try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
				} catch {
					// print("创建目录失败: \(error)")
					return nil
				}
			}
		} else {
			fileURL = try! FileManager.default
				.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
				.appendingPathComponent("\(fname).db")
		}
		
		var dbPointer: OpaquePointer?
		if sqlite3_open(fileURL.path, &dbPointer) == SQLITE_OK {
			db = dbPointer
			if config.encryption && config.password != nil {
				_ = run("PRAGMA key = ?", params: [config.password!])
			}
			self.fileURLPath = fileURL
			return db
		} else {
			sqlite3_close(dbPointer)
			return nil
		}
    }
    
    // 执行SQL查询
    func run(_ sql: String, params: [Any] = []) -> SQLiteResultBySt {
        guard let db = db else {
            return SQLiteResultBySt(error: "Database not initialized")
        }
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            return SQLiteResultBySt(error: errmsg)
        }
        
        for (index, param) in params.enumerated() {
            let idx = Int32(index + 1)
            
            switch param {
            case let text as String:
                sqlite3_bind_text(statement, idx, (text as NSString).utf8String, -1, nil)
            case let num as Int:
                sqlite3_bind_int64(statement, idx, Int64(num))
            case let num as Int64:
                sqlite3_bind_int64(statement, idx, num)
            case let num as Double:
                sqlite3_bind_double(statement, idx, num)
            case let data as Data:
                data.withUnsafeBytes { bytes in
                    sqlite3_bind_blob(statement, idx, bytes.baseAddress, Int32(data.count), nil)
                }
            case is NSNull:
                sqlite3_bind_null(statement, idx)
            default:
                "\(param)".utf8CString.withUnsafeBufferPointer { cString in
                    sqlite3_bind_text(statement, idx, cString.baseAddress, -1, nil)
                }
            }
        }
        
        let result = sqlite3_step(statement)
        
        if result != SQLITE_DONE && result != SQLITE_ROW {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(statement)
            return SQLiteResultBySt(error: errmsg)
        }
        
        let changes = sqlite3_changes(db)
        let lastId = sqlite3_last_insert_rowid(db)
        
        sqlite3_finalize(statement)
        
        return SQLiteResultBySt(changes: Int(changes), lastInsertRowid: lastId)
    }
    
    // 查询数据
    func query(_ sql: String, params: [Any] = []) -> SQLiteResultBySt {
        guard let db = db else {
            return SQLiteResultBySt(error: "Database not initialized")
        }
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            return SQLiteResultBySt(error: errmsg)
        }
        
        for (index, param) in params.enumerated() {
            let idx = Int32(index + 1)
            
            switch param {
            case let text as String:
                sqlite3_bind_text(statement, idx, (text as NSString).utf8String, -1, nil)
            case let num as Int:
                sqlite3_bind_int64(statement, idx, Int64(num))
            case let num as Int64:
                sqlite3_bind_int64(statement, idx, num)
            case let num as Double:
                sqlite3_bind_double(statement, idx, num)
            case let data as Data:
                data.withUnsafeBytes { bytes in
                    sqlite3_bind_blob(statement, idx, bytes.baseAddress, Int32(data.count), nil)
                }
            case is NSNull:
                sqlite3_bind_null(statement, idx)
            default:
                "\(param)".utf8CString.withUnsafeBufferPointer { cString in
                    sqlite3_bind_text(statement, idx, cString.baseAddress, -1, nil)
                }
            }
        }
        
        var rows: [[Any]] = []
        var columns: [String] = []
        var maps: [[String: Any]] = []
        
        // 获取列名
        let columnCount = sqlite3_column_count(statement)
        for i in 0..<columnCount {
            if let name = sqlite3_column_name(statement, i) {
                columns.append(String(cString: name))
            }
        }
        
        // 获取数据
        while sqlite3_step(statement) == SQLITE_ROW {
            var row: [Any] = []
            var map: [String: Any] = [:]
            
            for i in 0..<columnCount {
                let type = sqlite3_column_type(statement, i)
                let columnName = columns[Int(i)]
                var value: Any = ""
                
                switch type {
                case SQLITE_TEXT:
                    if let text = sqlite3_column_text(statement, i) {
                        value = String(cString: text)
                    }
                case SQLITE_INTEGER:
                    value = sqlite3_column_int64(statement, i)
                case SQLITE_FLOAT:
                    value = sqlite3_column_double(statement, i)
                case SQLITE_BLOB:
                    let blobLength = sqlite3_column_bytes(statement, i)
                    if let blobData = sqlite3_column_blob(statement, i) {
                        value = Data(bytes: blobData, count: Int(blobLength))
                    } else {
                        value = Data()
                    }
                default:
                    value = ""
                }
                
                row.append(value)
                map[columnName] = value
            }
            
            rows.append(row)
            maps.append(map)
        }
        
        sqlite3_finalize(statement)
        
        return SQLiteResultBySt(rows: rows, columns: columns, maps: maps)
    }
    
    // 插入数据
    func insert(table: String, data: [String: Any]) -> SQLiteResultBySt {
        let keys = Array(data.keys)
        let values = keys.map { data[$0]! }
        
        let sql = "INSERT INTO \(table) (\(keys.joined(separator: ","))) VALUES (\(keys.map { _ in "?" }.joined(separator: ",")))"
        return run(sql, params: values)
    }
    
    // 更新数据
    func update(table: String, data: [String: Any], where: String, params: [Any] = []) -> SQLiteResultBySt {
        let keys = Array(data.keys)
        var values = keys.map { data[$0]! }
        
        let sets = keys.map { "\($0) = ?" }.joined(separator: ",")
        values.append(contentsOf: params)
        
        let sql = "UPDATE \(table) SET \(sets) WHERE \(`where`)"
        return run(sql, params: values)
    }
    
    // 删除数据
    func delete(table: String, where: String, params: [Any] = []) -> SQLiteResultBySt {
        let sql = "DELETE FROM \(table) WHERE \(`where`)"
        return run(sql, params: params)
    }
    
    // 保存数据库到本地
    func saveLocal(filename: String? = nil) -> SQLiteResultBySt {
        guard let db = self.db else {
            return SQLiteResultBySt(error: "Database not initialized")
        }
        
        do {
            let fname = filename ?? "sqlite"
            let fileManager = FileManager.default
            
            // 使用配置的默认目录或系统文档目录
            let targetDir = self.config.defaultDirectory != nil ? URL(fileURLWithPath: self.config.defaultDirectory!) : fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            // 获取当前数据库文件的路径
            var dbPath = String(cString: sqlite3_db_filename(self.db!, nil))
            
            // 如果dbPath为空，则使用fileURLPath或默认路径
            if dbPath.isEmpty {
                if let fileURL = self.fileURLPath {
                    dbPath = fileURL.path
                } else {
                    return SQLiteResultBySt(error: "无法获取数据库文件路径")
                }
            }
            
            let sourceUrl = URL(fileURLWithPath: dbPath)
            let targetUrl = targetDir.appendingPathComponent("\(fname).db")
            
            // 检查源文件是否存在和可读
            if !fileManager.fileExists(atPath: sourceUrl.path) {
                return SQLiteResultBySt(error: "未能找到数据库文件")
            }
            
            guard let sourceAttrs = try? fileManager.attributesOfItem(atPath: sourceUrl.path),
                  sourceAttrs[.size] as? UInt64 ?? 0 > 0 else {
                return SQLiteResultBySt(error: "数据库文件无效或损坏")
            }
            
            // 确保数据库处于一致状态
            sqlite3_exec(db, "PRAGMA wal_checkpoint(FULL)", nil, nil, nil)
            
            // 创建临时文件
            let tempUrl = targetDir.appendingPathComponent("\(fname)_temp.db")
            
            // 如果临时文件存在则删除
            if fileManager.fileExists(atPath: tempUrl.path) {
                try fileManager.removeItem(at: tempUrl)
            }
            
            // 先复制到临时文件
            try fileManager.copyItem(at: sourceUrl, to: tempUrl)
            
            // 验证临时文件
            guard let tempAttrs = try? fileManager.attributesOfItem(atPath: tempUrl.path),
                  tempAttrs[.size] as? UInt64 ?? 0 > 0 else {
                try? fileManager.removeItem(at: tempUrl)
                return SQLiteResultBySt(error: "备份文件创建失败")
            }
            
            // 如果目标文件存在则删除
            if fileManager.fileExists(atPath: targetUrl.path) {
                try fileManager.removeItem(at: targetUrl)
            }
            
            // 将临时文件移动到目标位置
            try fileManager.moveItem(at: tempUrl, to: targetUrl)
            
            return SQLiteResultBySt()
        } catch {
            return SQLiteResultBySt(error: error.localizedDescription)
        }
    }
    
    // 从本地加载数据库
    func loadLocal(filename: String) -> SQLiteResultBySt {
        let fileManager = FileManager.default
        let sourceDir = self.config.defaultDirectory != nil ? URL(fileURLWithPath: self.config.defaultDirectory!) : fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let sourceUrl = sourceDir.appendingPathComponent("\(filename).db")
        let targetUrl = sourceDir.appendingPathComponent("sqlite.db")
        
        do {
            // 检查源文件是否存在和可读
            if !fileManager.fileExists(atPath: sourceUrl.path) {
                return SQLiteResultBySt(error: "没有数据库")
            }
            
            guard let sourceAttrs = try? fileManager.attributesOfItem(atPath: sourceUrl.path),
                  sourceAttrs[.size] as? UInt64 ?? 0 > 0 else {
                return SQLiteResultBySt(error: "数据库文件无效或损坏")
            }
            
            // 创建临时文件
            let tempUrl = sourceDir.appendingPathComponent("\(filename)_temp.db")
            
            // 如果临时文件存在则删除
            if fileManager.fileExists(atPath: tempUrl.path) {
                try fileManager.removeItem(at: tempUrl)
            }
            
            // 先复制到临时文件
            try fileManager.copyItem(at: sourceUrl, to: tempUrl)
            
            // 验证临时文件
            guard let tempAttrs = try? fileManager.attributesOfItem(atPath: tempUrl.path),
                  tempAttrs[.size] as? UInt64 ?? 0 > 0 else {
                try? fileManager.removeItem(at: tempUrl)
                return SQLiteResultBySt(error: "数据库文件损坏")
            }
            
            // 如果目标文件存在则删除
            if fileManager.fileExists(atPath: targetUrl.path) {
                try fileManager.removeItem(at: targetUrl)
            }
            
            // 将临时文件移动到目标位置
            try fileManager.moveItem(at: tempUrl, to: targetUrl)
            
            // 尝试打开数据库
            if let _ = self.createDb() {
                return SQLiteResultBySt()
            } else {
                return SQLiteResultBySt(error: "数据库文件损坏")
            }
        } catch {
            // 清理临时文件
            let tempUrl = sourceDir.appendingPathComponent("\(filename)_temp.db")
            try? fileManager.removeItem(at: tempUrl)
            
            return SQLiteResultBySt(error: "数据库文件损坏")
        }
    }
    
    // 设置默认目录
    func setDefaultDirectory(directory: String) {
        self.config.defaultDirectory = directory
    }

    // 设置密码
    func setPassword(_ password: String?) {
        config.password = password
        config.encryption = password != nil && !password!.isEmpty
    }
    
    // 检查表是否存在
    func tableExists(tableName: String) -> Bool {
        let result = query("SELECT name FROM sqlite_master WHERE type='table' AND name=?", params: [tableName])
        return (result.rows?.isEmpty == false)
    }
    
    // 创建数据表
    func createTable(tableName: String, columns: [String: String]) -> SQLiteResultBySt {
        let columnDefinitions = columns.map { key, value in "\(key) \(value)" }.joined(separator: ",")
        let sql = "CREATE TABLE IF NOT EXISTS \(tableName) (\(columnDefinitions))"
        return run(sql)
    }
    
    // 删除数据表
    func dropTable(tableName: String) -> SQLiteResultBySt {
        let sql = "DROP TABLE IF EXISTS \(tableName)"
        return run(sql)
    }
    
    // 关闭数据库
    func close() {
        if let db = db {
            sqlite3_close(db)
            self.db = nil
        }
    }
    
    // 开始事务
    func beginTransaction() -> SQLiteResultBySt {
        if isInTransaction {
            return SQLiteResultBySt(error: "Transaction already in progress")
        }
        
        isInTransaction = true
        return run("BEGIN TRANSACTION")
    }
    
    // 提交事务
    func commit() -> SQLiteResultBySt {
        if !isInTransaction {
            return SQLiteResultBySt(error: "No transaction in progress")
        }
        
        isInTransaction = false
        return run("COMMIT")
    }
    
    // 回滚事务
    func rollback() -> SQLiteResultBySt {
        if !isInTransaction {
            return SQLiteResultBySt(error: "No transaction in progress")
        }
        
        isInTransaction = false
        return run("ROLLBACK")
    }
    
    // 批量执行SQL
    func executeBatch(statements: [SQLiteExecuteBatchParamsBySt]) -> [SQLiteResultBySt] {
        var results: [SQLiteResultBySt] = []
        var hasError = false
        
        let wasInTransaction = isInTransaction
        if !wasInTransaction {
            _ = beginTransaction()
        }
        
        for stmt in statements {
            let result = run(stmt.sql, params: stmt.params ?? [])
            results.append(result)
            
            if result.error != nil {
                hasError = true
                break
            }
        }
        
        if hasError && !wasInTransaction {
            _ = rollback()
        } else if !wasInTransaction {
            _ = commit()
        }
        
        return results
    }
	// 获取数据库文件路径
	func getDatabasePath() -> String? {
		let fileManager = FileManager.default
	    guard let db = self.db else {
	        return nil
	    }
	    
	    do {
	        // 获取当前数据库文件路径
	        var dbPath = String(cString: sqlite3_db_filename(self.db!, nil))
	        
	        // 如果dbPath为空，则使用fileURLPath或默认路径
	        if dbPath.isEmpty {
	            if let fileURL = self.fileURLPath {
	                dbPath = fileURL.path
	            } else {
	                return nil
	            }
	        }
	        
	        // 获取缓存目录
	        let cacheURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
	        let tempURL = cacheURL.appendingPathComponent("tmui4x_xSqlite_DbackTemp.db")
			
			// 如果临时文件存在则删除
			if fileManager.fileExists(atPath: tempURL.path) {
			    try fileManager.removeItem(at: tempURL)
			}
	        
	        // 复制数据库文件到缓存目录
	        try FileManager.default.copyItem(atPath: dbPath, toPath: tempURL.path)
	        
	        return tempURL.path
	    } catch {
	        return nil
	    }
	}
}

