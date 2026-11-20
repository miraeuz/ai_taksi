"""Basic browser interaction tests. Requires playwright + local Chromium."""
import asyncio
from pathlib import Path
from playwright.async_api import async_playwright

HTML = Path(__file__).with_name('index.html')

async def test():
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(headless=True,
            executable_path='/usr/bin/chromium', args=['--no-sandbox'])
        desktop = await browser.new_page(viewport={'width': 1360, 'height': 900})
        errors=[]; requests=[]
        desktop.on('pageerror', lambda e: errors.append(str(e)))
        desktop.on('request', lambda r: requests.append(r.url))
        await desktop.set_content(HTML.read_text(), wait_until='domcontentloaded')
        await desktop.screenshot(path=str(HTML.with_name('desktop.png')))
        assert await desktop.get_by_text('Salom, Aziza 👋').count() == 1
        # Passenger: confirmation -> offer -> booking -> chat/privacy -> trip/rating.
        await desktop.get_by_role('button', name='Boraman').click()
        await desktop.locator('#nav').get_by_role('button', name='Safarlar').click()
        await desktop.get_by_role('button', name='Joyni tasdiqlash').click()
        await desktop.get_by_role('button', name='Xavfsiz chat').click()
        assert await desktop.get_by_text('Safar chati').count() >= 1
        await desktop.locator('#chatInput').fill('+998901234567')
        await desktop.get_by_role('button', name='Xabar yuborish').click()
        assert await desktop.get_by_text('Telefon, @username va havolalar yuborilmaydi').count() >= 1
        await desktop.locator('#chatInput').fill('Men bekatdaman')
        await desktop.get_by_role('button', name='Xabar yuborish').click()
        assert await desktop.locator('.bubble.mine').get_by_text('Men bekatdaman').count() == 1
        await desktop.get_by_role('button', name='Orqaga').click()
        await desktop.get_by_role('button', name='Safarni boshlash · demo').click()
        await desktop.get_by_role('button', name='Safarni yakunlash · demo').click()
        await desktop.get_by_role('button', name='5 yulduz').click()
        assert await desktop.get_by_text('RAHMAT! BAHO SAQLANDI').count() == 1
        # Schedule editing.
        await desktop.locator('#nav').get_by_role('button', name='Jadval').click()
        await desktop.locator('#pickupSelect').select_option('Kosonsoy bozori')
        await desktop.locator('#arriveTime').fill('12:30')
        await desktop.get_by_role('button', name='Jadvalni saqlash').click()
        await desktop.locator('#nav').get_by_role('button', name='Asosiy').click()
        assert await desktop.get_by_text('12:30 gacha').count() == 1
        # Driver: offer -> pickup -> price change.
        await desktop.get_by_role('button', name='Haydovchi demo').click()
        assert await desktop.get_by_text('Salom, Sherzod 👋').count() == 1
        await desktop.locator('#nav').get_by_role('button', name='Takliflar').click()
        await desktop.get_by_role('button', name='Qabul qilish').first.click()
        await desktop.get_by_role('button', name='Bekatlar ro‘yxati').click()
        await desktop.get_by_role('button', name='01 Kosonsoy markazi 10:40 · 3 yo‘lovchi').click()
        assert await desktop.locator('.pickup-index.done').count() == 1
        await desktop.get_by_role('button', name='Orqaga').click()
        await desktop.locator('#nav').get_by_role('button', name='Narxlar').click()
        await desktop.get_by_role('button', name='8 yo‘lovchi narxini tahrirlash').click()
        await desktop.locator('#priceInput').fill('22000')
        await desktop.get_by_role('button', name='Saqlash').click()
        assert await desktop.get_by_text('22 000 so‘m').count() >= 1
        await desktop.screenshot(path=str(HTML.with_name('driver.png')))
        assert not errors, errors
        assert not requests, requests
        print('PASS: interactive passenger, chat privacy, schedule, driver, pickup, and pricing flows')
        print('PASS: no page errors; no network requests')
        mobile = await browser.new_page(viewport={'width':390,'height':844}, device_scale_factor=1)
        await mobile.set_content(HTML.read_text(),wait_until='domcontentloaded')
        assert await mobile.locator('.story').is_visible() is False
        await mobile.screenshot(path=str(HTML.with_name('mobile.png')))
        print('PASS: mobile responsive layout at 390 x 844')
        await browser.close()

if __name__ == '__main__':
    asyncio.run(test())
