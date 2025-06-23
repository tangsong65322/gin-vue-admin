jest.setTimeout(15000);

const platformInfo = process.env.uniTestPlatformInfo.toLocaleLowerCase()
const isAndroid = platformInfo.startsWith('android')
const isIos = platformInfo.startsWith('ios')
const isApp = isAndroid || isIos
const isWeb = platformInfo.startsWith('web')
const isMP = platformInfo.startsWith('mp')
const isAppWebview = !!process.env.UNI_AUTOMATOR_APP_WEBVIEW
let page;
let pageIndex = 0
const pages = [
	"/pages/index/index",
	"/pages/index/global",
	"/pages/chongyong/button",
]

describe("page screenshot test", () => {
	if (platformInfo.indexOf('safari') !== -1) {
		it('暂时规避 safari 截图测试', () => {
			expect(1).toBe(1)
		})
		return
	}

	beforeAll(() => {
		console.log("page screenshot test start");
	});
	beforeEach(async () => {
		const currentPagePath = pages[pageIndex]
		page = await program.navigateTo(currentPagePath);
		await page.waitFor(3000);
	});
	afterEach(() => {
		pageIndex++;
	});
	afterAll(() => {
		console.log("page screenshot test finish");
	});
	test.each(pages)("%s", async () => {
		let names = pages[pageIndex].split("/")
		let name = names[names.length-1]
		const screenshotParams = {
			path: "jtest/screenshot/"+name+".png"
		}
	
		await program.screenshot(screenshotParams);
		await page.waitFor(800);
	});
});