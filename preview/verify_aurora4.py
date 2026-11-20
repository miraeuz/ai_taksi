from pathlib import Path
import base64
from playwright.sync_api import sync_playwright
from PIL import Image,ImageDraw,ImageFont,ImageFilter
root=Path(__file__).resolve().parent
html=(root/'index.html').read_text().replace('<link rel="stylesheet" href="styles.css">','').replace('<script src="app.js"></script>','')
css=(root/'styles.css').read_text()
js=(root/'app.js').read_text().replace('assets/vehicle_scene.webp','data:image/webp;base64,'+base64.b64encode((root/'assets/vehicle_scene.webp').read_bytes()).decode())
checks=[]
with sync_playwright() as p:
 browser=p.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox'])
 page=browser.new_page(viewport={'width':1440,'height':920},device_scale_factor=1)
 errors=[];requests=[]
 page.on('pageerror',lambda err: errors.append(str(err)))
 page.on('request',lambda req: requests.append(req.url))
 page.set_content(html);page.add_style_tag(content=css);page.add_script_tag(content=js)
 page.locator('.device').screenshot(path=str(root/'aurora4_light.png'))
 checks.append(('light theme screenshot',page.locator('body:not(.night)').count()==1))
 page.locator('#themeBtn').click()
 checks.append(('dark mode toggle',page.locator('body.night').count()==1))
 checks.append(('dark mode readable foreground',page.locator('.app-content').evaluate('(e)=>getComputedStyle(e).backgroundColor')!='rgb(246, 248, 255)'))
 page.locator('.device').screenshot(path=str(root/'aurora4_dark.png'))
 page.locator('#themeBtn').click()
 checks.append(('return to light mode',page.locator('body.night').count()==0))
 # Keep functionality and UI intact after theme switching.
 page.get_by_role('button',name='✓ Boraman').click()
 checks.append(('rider confirmation preserved',page.get_by_text('Mos transport topildi').count()>0))
 page.locator('#bottomNav button').nth(3).click()
 page.get_by_role('button',name='Haydovchi ilovasi').click()
 page.locator('#bottomNav button').nth(1).click()
 page.locator('.device').screenshot(path=str(root/'aurora4_driver.png'))
 checks.append(('driver offers preserved',page.get_by_text('Sprinter').count()>0))
 page.locator('#themeBtn').click()
 page.locator('.device').screenshot(path=str(root/'aurora4_driver_dark.png'))
 checks.append(('driver dark mode',page.locator('body.night').count()==1))
 checks.append(('no script errors',not errors))
 checks.append(('no external requests',not requests))
 mobile=browser.new_page(viewport={'width':390,'height':844},device_scale_factor=1)
 mobile.set_content(html);mobile.add_style_tag(content=css);mobile.add_script_tag(content=js)
 mobile.screenshot(path=str(root/'aurora4_mobile.png'),full_page=True)
 checks.append(('responsive mobile layout',mobile.locator('.device').is_visible()))
 browser.close()
print('\n'.join(('PASS' if ok else 'FAIL')+' '+name for name,ok in checks))
if errors:print('JS errors:',errors)
if requests:print('Network requests:',requests)
assert all(ok for _,ok in checks)

W,H=1670,1025
base=Image.new('RGBA',(W,H),(8,12,31,255))
d=ImageDraw.Draw(base)
for y in range(H):
 d.line([(0,y),(W,y)],fill=(int(7+10*y/H),int(12+8*y/H),int(29+22*y/H),255),width=1)
glow=Image.new('RGBA',(W,H),(0,0,0,0));gd=ImageDraw.Draw(glow)
gd.ellipse((-280,-360,760,500),fill=(108,40,251,100));gd.ellipse((1070,510,1940,1300),fill=(0,214,228,72))
base=Image.alpha_composite(base,glow.filter(ImageFilter.GaussianBlur(120)))
d=ImageDraw.Draw(base)
font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'; bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
ft=ImageFont.truetype(bold,46); fs=ImageFont.truetype(font,19); fl=ImageFont.truetype(bold,17)
d.text((70,30),'AI TAKSI / AURORA 4',font=ft,fill='#FFFFFF')
d.text((73,93),'Slide-inspired light & dark mobile design  •  Offline interactive concept',font=fs,fill='#B9C7EA')
pics=['aurora4_light.png','aurora4_dark.png','aurora4_driver_dark.png']
titles=['01  YO‘LOVCHI / LIGHT','02  YO‘LOVCHI / DARK','03  HAYDOVCHI / DARK']
for i,(f,name) in enumerate(zip(pics,titles)):
 im=Image.open(root/f).convert('RGBA');h=775;w=round(im.width*h/im.height);im=im.resize((w,h),Image.Resampling.LANCZOS)
 x=70+i*540+(460-w)//2;y=154
 sh=Image.new('RGBA',(w+50,h+50),(0,0,0,0));ImageDraw.Draw(sh).rounded_rectangle((24,24,w+24,h+24),radius=49,fill=(0,0,0,150))
 base.alpha_composite(sh.filter(ImageFilter.GaussianBlur(18)),(x-24,y-12));base.alpha_composite(im,(x,y))
 d.text((86+i*540,952),name,font=fl,fill='#49F0F0')
 d.line((86+i*540,982,487+i*540,982),fill='#8562CC',width=2)
base.convert('RGB').save(root/'aurora4_showcase.png',quality=94)
print('Showcase saved:',root/'aurora4_showcase.png')
