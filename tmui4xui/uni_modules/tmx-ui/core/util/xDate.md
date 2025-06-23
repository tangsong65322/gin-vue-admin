# xDate

### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

日期处理库

### 说明
这是tmui4.0|XUI的日期处理库，提供了丰富的日期操作功能。简单好上手，单库只有14kb，能满足大部分日期处理需求。库采用类Jq式的链式调用，使用灵活方便。

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 导入使用
在页面中直接使用快捷导入即可使用，它是class类，需要new
```ts
import {xDate, createDate} from "@/uni_modules/tmx-ui/index.uts"
// 打印当前
console.log(new xDate().date)
// 辅助函数用来创建系统的Date对象时间
console.log(createDate('2023-3-1'))
```

### 创建实例
支持string, number, Date, null四种类型
```ts
import {xDate, createDate} from "@/uni_modules/tmx-ui/index.uts"
// 为空，默认是现在
const now = new xDate()
// 传递字符串的毫秒数
const date1 = new xDate('15888888')
// 传递字符串的时间
const date2 = new xDate('2023-2-3')
const date3 = new xDate('2023/2/3')
// 传递Date对象
const date4 = new xDate(new Date())
```
### 实例方法
| 名称 | 参数 | 介绍 |
| --- | --- | --- |
| format | s: string \| null = null | 格式化日期，默认格式为YYYY/MM/DD hh:mm:ss |
| getYear | 无 | 获取当前年份 |
| getMonth | 无 | 获取当前月份（0-11，0代表1月） |
| getMonthName | useShort: boolean = false | 获取当前月份的名称（支持国际化） |
| getDate | 无 | 获取当前日（1-31） |
| getHours | 无 | 获取当前小时（0-23） |
| getMinutes | 无 | 获取当前分钟（0-59） |
| getSeconds | 无 | 获取当前秒（0-59） |
| getDateOf | d: xDateTypeTime = 'd' | 获取指定类型的数据，d可为'y'年,'m'月,'d'日,'h'时,'M'分,'s'秒,'ms'毫秒,'w'周 |
| setDateOf | n: number, d: xDateTypeTime = 'd' | 设定日期，支持链式调用 |
| getTime | d: xDateTypeTime | 获取时间戳，可指定单位 |
| getClone | 无 | 获取当前时间的副本 |
| getWeek | 无 | 获取本年的第几周 |
| getDateStartOf | d: 'm' \| 'w' \| 'y' = 'm' | 获取时间的第一天（月/周/年） |
| getDateEndOf | d: 'm' \| 'w' \| 'y' = 'm' | 获取时间的最后一天（月/周/年） |
| getWeekDay | 无 | 获取星期几（0-6，0表示星期天） |
| getWeekDayCn | model: string[] \| null = null, useShort: boolean = true | 获取星期名称（支持国际化） |
| getMonthCountDay | 无 | 获取当前月份的最大天数 |
| getDateInfo | str: string \| null = null | 获取日期详细信息 |
| getDaysOf | d: 'm' \| 'w' = 'm' | 获取日期数组（月/周） |
| add | count: number, d: xDateTypeTime = 'd' | 日期加法操作，支持链式调用 |
| subtraction | count: number, d: xDateTypeTime = 'd' | 日期减法操作，支持链式调用 |
| isBetween | start: xDate, end: xDate, type: xDateTypeTime = 'ms', d: '()' \| '[]' \| '(]' \| '[)' = '[]' | 判断日期是否在区间内 |
| isBetweenOf | targetDate: xDate, d: '>' \| '>=' \| '<' \| '<=' \| '=' = '>', type: xDateTypeTime = 'ms' | 与目标日期比较 |
| fromBetweenLongTime | target: any, model: Map<number, string> \| null, format: string \| null | 计算与目标时间过了多久（支持国际化） |
| diffTime | target: any, type: xDateTypeTime = 's' | 计算与目标时间相差多少个单位 |
| getQuarter | type: string = '' | 获取季度信息 |
| setDateLocale | locale: xDateLanguage | 设置xDate的语言 |
| getDateLocale | 无 | 获取当前xDate使用的语言 |


### 类型定义

```ts
// 日期时间单位类型
export type xDateTypeTime = 'y' | 'm' | 'd' | 'h' | 'M' | 's' | 'ms' | 'w'

// 季度信息类型
export type xDateTypeQuarter = {
	quarter : number,
	start : string,
	end : string
}

// 日期格式类型
export type DateFormat = 'RFC2822' | 'ISO8601' | 'CUSTOM';

// 日期信息类型
export type xDateDayInfoType = {
	year: number,
	month: number,
	day: number,
	hours: number,
	minutes: number,
	seconds: number,
	week: number,
	weeks: number,
	weekCn: string,
	date: string
}

// 支持的语言类型
export type xDateLanguage = 'zh-Hans' | 'en' | 'ja' | 'ko' | 'zh-Hant' | 'fr' | 'ru';

// 国际化相对时间配置类型
export type xDateI18nTypeRelativeTime = {
    future: string,
    past: string,
    s: string,
    m: string,
    mm: string,
    h: string,
    hh: string,
    d: string,
    dd: string,
    M: string,
    MM: string,
    y: string,
    yy: string
}

// 国际化配置类型
export type xDateI18nType = {
    weekdays: string[],
    weekdaysShort: string[],
    months: string[],
    monthsShort: string[],
    meridiem: (hour: number, minute: number, isLowercase: boolean) => string,
    relativeTime: xDateI18nTypeRelativeTime
}
```

### 国际化相关API

```ts
// 设置xDate的语言
setDateLocale(locale: xDateLanguage): void

// 获取当前xDate使用的语言
getDateLocale(): xDateLanguage

// 获取当前月份的名称
getMonthName(useShort: boolean = false): string

// 获取星期名称（支持国际化）
getWeekDayCn(model: string[] | null = null, useShort: boolean = true): string
```
```

### API说明

#### 辅助函数

##### createDate
```ts
function createDate(dateStrs: string): Date
```
- 描述：用来解析非标准时间以及各种奇怪的时间格式
- 参数：
  - dateStrs: 日期字符串，支持多种格式如YYYY、YYYY-MM、YYYY-MM-DD等
- 返回值：Date对象

##### dateCovertXdate
```ts
function dateCovertXdate(date: Date): xDate
```
- 描述：将一个日期转换为xDate对象
- 参数：
  - date: Date对象
- 返回值：xDate对象

#### xDate类方法

##### 构造函数
```ts
constructor(dateStr: string | number | Date | null = null)
```
- 描述：创建xDate实例
- 参数：
  - dateStr: 可以是字符串、数字、Date对象或null（默认为当前时间）

##### detectDateFormat
```ts
detectDateFormat(dateStr: string): DateFormat
```
- 描述：检测字符串的日期格式类型
- 参数：
  - dateStr: 日期字符串
- 返回值：日期格式类型（'RFC2822'、'ISO8601'或'CUSTOM'）

##### format
```ts
format(s: string | null = null): string
```
- 描述：格式化日期
- 参数：
  - s: 模板，比如YYYY/MM/DD hh:mm:ss，默认为YYYY/MM/DD hh:mm:ss
- 返回值：格式化后的日期字符串

##### getYear
```ts
getYear(): number
```
- 描述：获取当前年
- 返回值：根据当地时间，返回一个对应于给定日期的年份数字

##### getMonth
```ts
getMonth(): number
```
- 描述：获取当前月（0-11，0代表1月）
- 返回值：一个0到11的整数值

##### getMonthName
```ts
getMonthName(useShort: boolean = false): string
```
- 描述：获取当前月份的名称（支持国际化）
- 参数：
  - useShort: 是否使用短名称，默认为false
- 返回值：返回当前语言环境下的月份名称

##### getDate
```ts
getDate(): number
```
- 描述：获取当前天
- 返回值：返回一个1到31的整数值

##### getHours
```ts
getHours(): number
```
- 描述：获取当前小时
- 返回值：返回一个0到23之间的整数值

##### getMinutes
```ts
getMinutes(): number
```
- 描述：获取当前分钟
- 返回值：返回一个0到59的整数值

##### getSeconds
```ts
getSeconds(): number
```
- 描述：获取当前秒
- 返回值：返回一个0到59的整数值

##### getDateOf
```ts
getDateOf(d: xDateTypeTime = 'd'): number
```
- 描述：获取指定类型的数据
- 参数：
  - d: 'y'年 'm'月 'd'日 'h'时 'M'分 's'秒 'ms'毫秒 'w'周
- 返回值：指定类型的数值

##### setDateOf
```ts
setDateOf(n: number, d: xDateTypeTime = 'd'): xDate
```
- 描述：设定日期
- 参数：
  - n: 设定的数据
  - d: 比如d=y，那么就是设置本日期的年份数据
- 返回值：xDate对象实例（支持链式调用）

##### getTime
```ts
getTime(d: xDateTypeTime): number
```
- 描述：获取时间戳
- 参数：
  - d: 'y'年 'm'月 'd'日 'h'时 'M'分 's'秒 'ms'毫秒
- 返回值：返回从UTC时间1970年1月1日午夜开始以毫秒为单位存储的时间值
- 注意：如果不提供d就默认返回毫秒，比如设置d=m那么后面的h,M,s,ms会被设置为0

##### getClone
```ts
getClone(): xDate
```
- 描述：当前时间的副本
- 返回值：新的xDate对象

##### getWeek
```ts
getWeek(): number
```
- 描述：本年的第几周
- 返回值：周次

##### getDateStartOf
```ts
getDateStartOf(d: 'm' | 'w' | 'y' = 'm'): xDate
```
- 描述：取时间的第一天
- 参数：
  - d: 'm'表示取本月的第一天，'w'取本周的第一天，'y'表示本年的第一天
- 返回值：返回xDate对象

##### getDateEndOf
```ts
getDateEndOf(d: 'm' | 'w' | 'y' = 'm'): xDate
```
- 描述：取时间的最后一天
- 参数：
  - d: 'm'表示取本月的最后一天，'w'取本周的最后一天，'y'表示本年的最后一天
- 返回值：返回xDate对象

##### getWeekDay
```ts
getWeekDay(): number
```
- 描述：根据本地时间，返回一个具体日期中一周的第几天，0表示星期天
- 返回值：根据本地时间，返回一个0到6之间的整数值

##### getWeekDayCn
```ts
getWeekDayCn(model: string[] | null = null, useShort: boolean = true): string
```
- 描述：获取星期名称（支持国际化）
- 参数：
  - model: 具有星期的中文模板，请按照顺序放置如["周日","周一","周二","周三","周四","周五","周六"]
  - useShort: 是否使用短名称，默认为true
- 返回值：返回当前语言环境下的星期名称

##### getMonthCountDay
```ts
getMonthCountDay(): number
```
- 描述：返回当前日期本月的最大天数
- 返回值：当前月份的最大天数

##### getDateInfo
```ts
getDateInfo(str: string | null = null): xDateDayInfoType
```
- 描述：返回当日的信息
- 参数：
  - str: 日期字符串，为null时使用当前xDate实例
- 返回值：返回一个包含年月日周次，星期，农历等的对象

##### getDaysOf
```ts
getDaysOf(d: 'm' | 'w' = 'm'): xDateDayInfoType[]
```
- 描述：返回日期数组
- 参数：
  - d: 'm'表示返回本月的日期数据，'w'表示返回本周的日期数据
- 返回值：返回一个日期数组

##### add
```ts
add(count: number, d: xDateTypeTime = 'd'): xDate
```
- 描述：为当前日期进行加操作
- 参数：
  - count: 要增加的数量
  - d: 'y'年 'm'月 'd'日 'h'时 'M'分 's'秒 'w'周
- 返回值：xDate对象（支持链式调用）

##### subtraction
```ts
subtraction(count: number, d: xDateTypeTime = 'd'): xDate
```
- 描述：为当前日期进行减操作
- 参数：
  - count: 要减少的数量
  - d: 'y'年 'm'月 'd'日 'h'时 'M'分 's'秒 'w'周
- 返回值：xDate对象（支持链式调用）

##### isBetween
```ts
isBetween(start: xDate, end: xDate, type: xDateTypeTime = 'ms', d: '()' | '[]' | '(]' | '[)' = '[]'): boolean
```
- 描述：日期是否在一个区间内
- 参数：
  - start: 开始日期
  - end: 结束日期
  - type: 要比较的单位，默认为ms
  - d: 区间类型，'()'不含起始'[]'包含起始'(]'不包含开始但包含结束'[)'包含开始但不包含结束
- 返回值：是否在区间内

##### isBetweenOf
```ts
isBetweenOf(targetDate: xDate, d: '>' | '>=' | '<' | '<=' | '=' = '>', type: xDateTypeTime = 'ms'): boolean
```
- 描述：与目标日期比较
- 参数：
  - targetDate: 要比较的日期
  - d: 比较类型，'>'大于目标日期，'>='大于等于目标'<'小于目标，'<='小于等于目标,'='全等
  - type: 要比较的单位
- 返回值：比较结果

##### fromBetweenLongTime
```ts
fromBetweenLongTime(target: any, model: Map<number, string> | null, format: string | null): string
```
- 描述：与目标时间过了多久（支持国际化）
- 参数：
  - target: 要对比的相对时间，如果填写null就表示当前时间以来的的多久
  - model: 如果为null或者为空的map采用默认值,map格式key表示以秒为单位的时间，value为对应的文本
  - format: 超过最大值最使用格式化日期，如果为null默认为YYYY-MM-DD
- 返回值：返回对应的时间文本

##### diffTime
```ts
diffTime(target: any, type: xDateTypeTime = 's'): number
```
- 描述：与目标时间相差多少个单位
- 参数：
  - target: 目标时间
  - type: 相差的单位，默认：s秒
- 返回值：返回以xDateTypeTime为单位相关的时间数

##### getQuarter
```ts
getQuarter(type: string = ''): xDateTypeQuarter[]
```
- 描述：获取季度
- 参数：
  - type: 'y'表示获取本年的4个季度，空值表示获取当前时间所在的季度
- 返回值：返回一个季度数组{quarter:number,start:string,end:string}

##### setDateLocale
```ts
setDateLocale(locale: xDateLanguage): void
```
- 描述：设置xDate的语言
- 参数：
  - locale: 语言代码，支持'zh-Hans'(中文简体)、'en'(英文)、'ja'(日文)、'ko'(韩文)、'zh-Hant'(繁体中文)、'fr'(法语)、'ru'(俄语)
- 返回值：无

##### getDateLocale
```ts
getDateLocale(): xDateLanguage
```
- 描述：获取当前xDate使用的语言
- 返回值：当前语言代码

### 使用示例

#### 基本使用
```ts
import {xDate, createDate} from "@/uni_modules/tmx-ui/index.uts"

// 创建日期实例
const date = new xDate('2023-05-15')

// 格式化日期
console.log(date.format('YYYY年MM月DD日')) // 输出: 2023年05月15日

// 获取年月日
console.log(date.getYear()) // 输出: 2023
console.log(date.getMonth()) // 输出: 4 (5月)
console.log(date.getDate()) // 输出: 15

// 链式调用
const nextWeek = date.getClone().add(1, 'w')
console.log(nextWeek.format()) // 输出下周同一天的日期

// 获取月份天数
console.log(date.getMonthCountDay()) // 输出: 31 (5月有31天)

// 获取日期信息
const info = date.getDateInfo()
console.log(info.weekCn) // 输出: 周一 (假设5月15日是周一)

// 日期比较
const date1 = new xDate('2023-01-01')
const date2 = new xDate('2023-12-31')
console.log(date.isBetween(date1, date2)) // 输出: true
```

#### 高级用法
```ts
import {xDate} from "@/uni_modules/tmx-ui/index.uts"

// 获取本月所有日期
const currentDate = new xDate()
const daysInMonth = currentDate.getDaysOf('m')
console.log(`本月共有 ${daysInMonth.length} 天`)

// 获取本周日期
const daysInWeek = currentDate.getDaysOf('w')
console.log(`本周的第一天是 ${daysInWeek[0].date}`)

// 获取季度信息
const quarters = currentDate.getQuarter('y')
console.log(`今年第一季度: ${quarters[0].start} 至 ${quarters[0].end}`)

// 计算两个日期之间的差距
const birthday = new xDate('1990-01-01')
const daysDiff = currentDate.diffTime(birthday, 'd')
console.log(`距离生日已经过去了 ${daysDiff} 天`)

// 友好的时间显示
const pastTime = new xDate().subtraction(3, 'h')
const timeText = currentDate.fromBetweenLongTime(pastTime, null, null)
console.log(timeText) // 输出: 3小时前
```

#### 国际化使用示例
```ts
import {xDate} from "@/uni_modules/tmx-ui/index.uts"

// 创建日期实例
const date = new xDate('2023-05-15')

// 默认使用中文简体
console.log(date.getWeekDayCn()) // 输出: 周一 (假设5月15日是周一)
console.log(date.getMonthName()) // 输出: 五月

// 切换到英文
date.setDateLocale('en')
console.log(date.getWeekDayCn()) // 输出: Mon
console.log(date.getMonthName()) // 输出: May
console.log(date.getMonthName(false)) // 输出: May (完整名称)

// 切换到日文
date.setDateLocale('ja')
console.log(date.getWeekDayCn()) // 输出: 月
console.log(date.getMonthName()) // 输出: 5月

// 相对时间显示也会根据语言环境变化
const currentDate = new xDate()
const pastTime = new xDate().subtraction(3, 'h')

// 中文环境
currentDate.setDateLocale('zh-Hans')
console.log(currentDate.fromBetweenLongTime(pastTime, null, null)) // 输出: 3小时前

// 英文环境
currentDate.setDateLocale('en')
console.log(currentDate.fromBetweenLongTime(pastTime, null, null)) // 输出: 3 hours ago

// 获取当前语言设置
console.log(currentDate.getDateLocale()) // 输出: en
```