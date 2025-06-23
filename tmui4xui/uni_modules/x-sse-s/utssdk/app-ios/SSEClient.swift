import Foundation

class SSEClient: NSObject {
    private var url: URL
    private var headers: [String: String]
    private var eventSourceTask: URLSessionDataTask?
    private var onMessageCallback: ((String) -> Void)?
    private var onOpenCallback: (() -> Void)?
    private var onErrorCallback: ((Error?) -> Void)?

    init(url: URL, headers: [String: String] = [:]) {
        self.url = url
        self.headers = headers
        super.init()
    }

    func onMessage(_ callback: @escaping (String) -> Void) {
        onMessageCallback = callback
    }

    func onOpen(_ callback: @escaping () -> Void) {
        onOpenCallback = callback
    }

    func onError(_ callback: @escaping (Error?) -> Void) {
        onErrorCallback = callback
    }

    func start() {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        var request = URLRequest(url: url)
        // 添加默认的SSE头信息
        request.addValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        // 添加自定义头信息
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        eventSourceTask = session.dataTask(with: request)
        eventSourceTask?.resume()
    }

    func stop() {
        eventSourceTask?.cancel()
    }
}

extension SSEClient: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let string = String(data: data, encoding: .utf8) else { return }
        let lines = string.components(separatedBy: .newlines)

        for line in lines {
            if line.isEmpty { continue }
            if line.hasPrefix("data: ") {
                let message = line.replacingOccurrences(of: "data: ", with: "")
                onMessageCallback?(message)
            }
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
        onOpenCallback?()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        onErrorCallback?(error)
    }
}
