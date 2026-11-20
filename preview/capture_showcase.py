from pathlib import Path
from playwright.sync_api import sync_playwright
from PIL import Image,ImageDraw,ImageFont,ImageFilter
import base64
root=Path(__file__).resolve().parent
html=(root/'index.html').read_text().replace('<link rel="stylesheet" href="styles.css">','').replace('<script src="app.js"></script>','')
css=(root/'styles.css').read_text()
js=(root/'app.js').read_text()
uri='data:image/webp;base64,'+base64.b64encode((root/'assets/vehicle_scene.webp').read_bytes()).decode()
js=js.replace('assets/vehicle_scene.webp',uri)
with sync_playwright() as p:
 browser=p.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox'])
 page=browser.new_page(viewport={'width':1440,'height':950},device_scale_factor=1)
 page.set_content(html);page.add_style_tag(content=css);page.add_script_tag(content=js)
 page.locator('.device').screenshot(path=str(root/'nova_rider.png'))
 page.evaluate("openPanel('fleet')")
 page.locator('.device').screenshot(path=str(root/'nova_fleet.png'))
 page.evaluate("switchRole('driver');setTab('offers')")
 page.locator('.device').screenshot(path=str(root/'nova_driver.png'))
 browser.close()
W,H=1500,1080
bg=Image.new('RGB',(W,H),'#090e24')
d=ImageDraw.Draw(bg)
for y in range(H):
 t=y/H
 d.line([(0,y),(W,y)],fill=(int(7+8*t),int(12+6*t),int(30+23*t)),width=1)
# blurred glows
layers=Image.new('RGBA',(W,H),(0,0,0,0));g=ImageDraw.Draw(layers)
g.ellipse((-260,-360,680,350),fill=(106,36,235,90));g.ellipse((1020,600,1820,1350),fill=(5,207,221,55))
bg=Image.alpha_composite(bg.convert('RGBA'),layers.filter(ImageFilter.GaussianBlur(125)))
d=ImageDraw.Draw(bg)
font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
title=ImageFont.truetype(bold,49); sub=ImageFont.truetype(font,19); labels=ImageFont.truetype(bold,16)
d.text((75,34),'AI TAKSI  /  NOVA',font=title,fill='#FFFFFF')
d.text((78,96),'New-generation interactive mobile experience  ·  Offline prototype',font=sub,fill='#AEBCE2')
files=['nova_rider.png','nova_fleet.png','nova_driver.png']
titles=['01  YO‘LOVCHI','02  SMART AVTOPARK','03  HAYDOVCHI']
for i,(file,titletext) in enumerate(zip(files,titles)):
 im=Image.open(root/file).convert('RGBA')
 # device screenshot 420x875; fit in height 823 retaining aspect
 h=810; w=round(im.width*h/im.height)
 im=im.resize((w,h),Image.Resampling.LANCZOS)
 x=73+i*490+(420-w)//2; y=151
 shadow=Image.new('RGBA',(w+50,h+50),(0,0,0,0));sh=ImageDraw.Draw(shadow)
 sh.rounded_rectangle((25,25,w+25,h+25),radius=47,fill=(0,0,0,170))
 bg.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(18)),(x-25,y-15))
 bg.alpha_composite(im,(x,y))
 d.text((78+i*490,989),titletext,font=labels,fill='#3EEFF0')
 d.line([(78+i*490,1022),(405+i*490,1022)],fill='#6B5EC0',width=2)
bg.convert('RGB').save(root/'nova_showcase.png',quality=95)
print(root/'nova_showcase.png')
