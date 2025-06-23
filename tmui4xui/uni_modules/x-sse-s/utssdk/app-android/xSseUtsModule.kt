package uts.sdk.modules.xSseUtsModule

import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.sse.EventSource
import okhttp3.sse.EventSourceListener
import okhttp3.sse.EventSources
import java.util.concurrent.TimeUnit

class SSEClient(private val url: String, private val headers: Map<String, String> = mapOf()) {
    private var eventSource: EventSource? = null
    private var isConnected = false
    private var listener: SSEListener? = null

    // 连接状态回调接口
    interface SSEListener {
        fun onOpen()
        fun onMessage(event: String?, data: String)
        fun onError(throwable: Throwable)
        fun onClosed()
    }

    private val client = OkHttpClient.Builder()
        .readTimeout(0, TimeUnit.SECONDS)  // SSE 需要禁用读取超时
        .retryOnConnectionFailure(true)
        .build()

    fun setListener(listener: SSEListener) {
        this.listener = listener
    }

    fun connect() {
        if (isConnected) return

        val request = Request.Builder()
            .url(url)
            .header("Accept", "text/event-stream")
            .header("Cache-Control", "no-cache")
            
        // 添加自定义头信息
        headers.forEach { (key, value) ->
            request.header(key, value)
        }
            
        val builtRequest = request.build()

        eventSource = EventSources.createFactory(client)
            .newEventSource(builtRequest, object : EventSourceListener() {
                override fun onOpen(eventSource: EventSource, response: Response) {
                    isConnected = true
                    listener?.onOpen()
                }

                override fun onEvent(
                    eventSource: EventSource,
                    id: String?,
                    type: String?,
                    data: String
                ) {
                    listener?.onMessage(type, data)
                }

                override fun onClosed(eventSource: EventSource) {
                    isConnected = false
                    listener?.onClosed()
                }

                override fun onFailure(
                    eventSource: EventSource,
                    t: Throwable?,
                    response: Response?
                ) {
                    isConnected = false
                    t?.let { listener?.onError(it) }
                }
            })
    }

    fun disconnect() {
        eventSource?.cancel()
        eventSource = null
        isConnected = false
    }

    fun isConnected(): Boolean = isConnected
}