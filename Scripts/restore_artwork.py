#!/usr/bin/env python3
"""Restore vector silhouettes from owner-supplied references. No image generation.
Usage: python restore_artwork.py /path/to/original_assets /path/to/layout-manifest.json
Requires numpy, Pillow, scipy, potrace, rsvg-convert. Originals are not redistributed.
"""
from pathlib import Path
import sys,json,hashlib,subprocess,tempfile,xml.etree.ElementTree as ET
import numpy as np
from PIL import Image
from scipy.ndimage import gaussian_filter
ROOT=Path(__file__).resolve().parents[1]
source=Path(sys.argv[1]); manifest=json.loads(Path(sys.argv[2]).read_text())
cat=ROOT/'Shared/Assets.xcassets';cat.mkdir(parents=True,exist_ok=True)
(cat/'Contents.json').write_text(json.dumps({'info':{'author':'xcode','version':1}}))
colors={'white':'#FAFAFA','green':'#47DC21','blue':'#008FFF','orange':'#FF8900','cyan':'#6FE6EE'}
lineage=[]
for entry in manifest:
 day=entry['day'];name=f'Animal{day}';p=source/f'openai_devday_{day}_square.png';original=Image.open(p).convert('RGB');ref=original.resize((1280,1280),Image.Resampling.LANCZOS)
 x0,y0,x1,y1=entry['animal_bounds']; crop=ref.crop((x0,y0,x1,y1));a=np.array(crop).astype(float);r,g,b=a[:,:,0],a[:,:,1],a[:,:,2];mx=a.max(2);mn=a.min(2)
 masks={'white':(mx-mn<mx*.27)&(mx>110),'green':(g>r*1.25)&(g>b*1.3)&(g>70),'orange':(r>g*1.15)&(g>b*1.3)&(r>80),'blue':(b>r*1.4)&(b>g*1.18)&(b>70),'cyan':(b>r*1.25)&(g>r*1.25)&(b<=g*1.18)&(b>75)}
 # A day-13 numeral barely touches the reference crop's lower right corner.
 if day==13:
  for k in masks:
   masks[k][max(0,865-y0):,max(0,870-x0):]=False
   masks[k][:max(0,280-y0),:max(0,380-x0)]=False
 parts=[]
 with tempfile.TemporaryDirectory() as tmp:
  for k,mask in masks.items():
   if not mask.any():continue
   smooth=gaussian_filter(mask.astype(float),.6 if original.width>1100 else .9)>.48
   pbm=Path(tmp)/f'{k}.pbm';Image.fromarray(np.where(smooth,0,255).astype('uint8')).convert('1').save(pbm)
   svg=Path(tmp)/f'{k}.svg';subprocess.run(['potrace',str(pbm),'-s','-o',str(svg),'--turdsize','3','--alphamax','.85','--opttolerance','.15'],check=True)
   root=ET.parse(svg).getroot();group=root.find('{http://www.w3.org/2000/svg}g');group.set('fill',colors[k]);parts.append(ET.tostring(group,encoding='unicode').replace('ns0:','').replace(':ns0',''))
 w,h=crop.size
 svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'+''.join(parts)+'</svg>'
 out=ROOT/'Artwork'/f'{name}.svg';out.write_text(svg)
 aset=cat/f'{name}.imageset';aset.mkdir(exist_ok=True);(aset/f'{name}.svg').write_text(svg)
 (aset/'Contents.json').write_text(json.dumps({'images':[{'filename':f'{name}.svg','idiom':'universal'}],'info':{'author':'xcode','version':1},'properties':{'preserves-vector-representation':True}},indent=2))
 png=ROOT/'Artwork'/f'{name}.png';subprocess.run(['rsvg-convert',str(out),'-o',str(png)],check=True)
 assert Image.open(png).mode=='RGBA' and Image.open(png).getchannel('A').getextrema()[0]==0
 lineage.append({'asset':name,'source_filename':p.name,'source_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bounds_at_1280':entry['animal_bounds'],'method':'source color masks, light contour smoothing, Potrace Bezier curves; no generative reinterpretation'})
(ROOT/'Artwork/provenance.json').write_text(json.dumps(lineage,indent=2))
print('Restored 22 vector illustrations and transparent PNGs.')
