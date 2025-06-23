# 使用说明
非微信端的图表使用全量的图表，源文件在hybrid中。
你可以自己在百度图表那下载

# 百度图表下载和编译

[下载](https://echarts.apache.org/zh/builder.html)

# 关于微信
由于微信对大小有包大小限制，默认只编译了几个图表类型，如果需要定制见上方链接，自己定制
由于模块导入uniappx不兼容js的一些导入方式,因此微信采用了require导入,但会导入sdk无法复制文件到编译目录
我和官方讲过,他们在排查
编译和发布后,将组件目录x-echart/echarts.simple.min.js文件手动复制到对应目录内:
dev目录:根目录/unpackage/dist/dev/mp-weixin/uni_modules/tmx-ui/components/x-echart/echarts.simple.min.js
发布目录:根目录/unpackage/dist/build/mp-weixin/uni_modules/tmx-ui/components/x-echart/echarts.simple.min.js
复制完后,会自动编译.echarts.simple.min.js这个文件有490kb大小,请注意分包控制.

#微信已知问题
事件无效,等我后期研究修复.
