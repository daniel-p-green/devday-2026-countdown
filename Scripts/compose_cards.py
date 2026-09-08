#!/usr/bin/env python3
"""Compose source-matched vector cards from restored contours and typeset text."""
from pathlib import Path
import json,html,subprocess
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.boundsPen import BoundsPen
ROOT=Path(__file__).resolve().parents[1]
fontroot=Path('/System/Library/Fonts')
fonts={}
for name in ['Arial.ttf','Arial Bold.ttf','Menlo.ttc']:
 p=fontroot/('Menlo.ttc' if name=='Menlo.ttc' else 'Supplemental/'+name)
 fonts[name]=TTFont(p,fontNumber=0)
def path_text(s,p,box,color):
 if s=='·':
  x0,y0,x1,y1=box;return f'<ellipse cx="{(x0+x1)/2}" cy="{(y0+y1)/2}" rx="{(x1-x0)/2}" ry="{(y1-y0)/2}" fill="{color}"/>'
 f=fonts[p];gs=f.getGlyphSet();cm=f.getBestCmap();advance=0;parts=[];bounds=[]
 for ch in s:
  gn=cm[ord(ch)];pen=SVGPathPen(gs);gs[gn].draw(pen);bp=BoundsPen(gs);gs[gn].draw(bp)
  if bp.bounds:
   l,b,r,t=bp.bounds;bounds.append((l+advance,b,r+advance,t));parts.append(f'<path transform="translate({advance} 0)" d="{pen.getCommands()}"/>')
  advance+=f['hmtx'][gn][0]
 left=min(b[0] for b in bounds);bottom=min(b[1] for b in bounds);right=max(b[2] for b in bounds);top=max(b[3] for b in bounds)
 x0,y0,x1,y1=box;sx=(x1-x0)/(right-left);sy=(y1-y0)/(top-bottom)
 return f'<g aria-label="{html.escape(s)}" fill="{color}" transform="translate({x0} {y0}) scale({sx} {-sy}) translate({-left} {-top})">'+''.join(parts)+'</g>'

for entry in json.loads((ROOT/'Artwork/layouts.json').read_text()):
 day=entry['day'];name=f'Card{day}'
 animal=(ROOT/'Artwork'/f'Animal{day}.svg').read_text()
 inner=animal[animal.index('>')+1:animal.rindex('</svg>')]
 x0,y0,x1,y1=entry['animal_bounds']
 parts=[f'<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="1280" viewBox="0 0 1280 1280"><rect width="1280" height="1280" fill="black"/><g transform="translate({x0} {y0})">{inner}</g>']
 for t in entry['text']:parts.append(path_text(t['text'],t['font'],t['bounds'],t['color']))
 parts.append('</svg>');svg=''.join(parts)
 folder=ROOT/'Shared/Assets.xcassets'/f'{name}.imageset';folder.mkdir(exist_ok=True)
 (folder/f'{name}.svg').write_text(svg)
 (folder/'Contents.json').write_text(json.dumps({'images':[{'filename':f'{name}.svg','idiom':'universal'}],'info':{'author':'xcode','version':1},'properties':{'preserves-vector-representation':True}},indent=2))
 (ROOT/'Artwork'/f'{name}.svg').write_text(svg)
print('Composed 22 source-matched vector cards.')

# Separate vector text layers let portrait exports reflow without stretching a square.
layouts=json.loads((ROOT/'Artwork/layouts.json').read_text())
def layer(name, records):
 x0=min(t['bounds'][0] for t in records);y0=min(t['bounds'][1] for t in records)
 x1=max(t['bounds'][2] for t in records);y1=max(t['bounds'][3] for t in records)
 body=''.join(path_text(t['text'],t['font'],t['bounds'],t['color']) for t in records)
 svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="{x1-x0}" height="{y1-y0}" viewBox="{x0} {y0} {x1-x0} {y1-y0}">{body}</svg>'
 folder=ROOT/'Shared/Assets.xcassets'/f'{name}.imageset';folder.mkdir(exist_ok=True)
 (folder/f'{name}.svg').write_text(svg)
 (folder/'Contents.json').write_text(json.dumps({'images':[{'filename':f'{name}.svg','idiom':'universal'}],'info':{'author':'xcode','version':1},'properties':{'preserves-vector-representation':True}},indent=2))
for entry in layouts:
 day=entry['day'];records=entry['text']
 layer(f'Number{day}',[t for t in records if t['text']==str(day)])
base=next(e for e in layouts if e['day']==21)['text']
layer('StoryHeader',base[:5])
layer('StoryFooter',base[-3:])
layer('StoryDays',[t for t in base if t['text']=='days to go'])
base=next(e for e in layouts if e['day']==1)['text']
layer('StoryDay',[t for t in base if t['text']=='day to go'])
