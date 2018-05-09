#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: Sebastian Rosenzweig
"""

#import sys
#sys.path.insert(0, '/home/srosenzweig/Programs/Python/')
#from cfl import readcfl
#from cfl import writecfl
#color = ["#348ea9","#ef4846","#52ba9b","#f48b37"]
#color_light = ["#89c2d4","#ef8e8d","#a0ccc5","#f4b481"]
#linestyle = ["-", "--", "-.", ":"]
#marker = ["o", "^", "s", "8"]

import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageOps
from optparse import OptionParser

global cm
global font_location
global fontcolor
global dpi 
dpi = (300,300)
global fontsize
global scale
scale = 4
global textborder
global textpad
global spacing

def img_resize(img,size):
	img.thumbnail(size, Image.ANTIALIAS)
#%%
def new_canvas(res, color='white'):
    return Image.new(cm, res, color=color)

# Get image resolution
def get_img_res(im):
    x, y = im.size
    return (x,y)

# Get information about an entry
def resolve(entry):
    pos = str(entry[0:2])
    orientation = str(entry[2])
    text = str(entry[4:])
    return (pos,orientation,text)

# Increase canvas size
def calc_canvas_res(img_res, entries):
    x,y = img_res
    for entry in entries:
        pos, orientation, text = resolve(entry)
        if ( pos[0] == "L" or pos[0] == "R"):
            x += textborder
        elif ( pos[0] == "T" or pos[0] == "B"):
            y += textborder
    return (x,y)

def calc_canvas_res_tile(imgs,rows,cols):
    cx = 0
    cy = 0
    cx = calc_offset("col", cols, 0, imgs) - spacing
    cy = calc_offset("row", 0, rows, imgs) - spacing
    return (cx,cy)
    

def calc_img_pos(entries):
    X,Y = (0,0)
    for entry in entries:
        pos = entry[0]
        if ( pos[0] == "L"):
            X += textborder
        if ( pos[0] == "T"):
            Y += textborder
    return (X,Y)

def calc_img_pos_tile(imgs, rows, cols):
    x,y = img_res
    imgs_pos = [ ([0] * cols) for row in range(rows) ]

    for c in range(cols):
	    for r in range(rows):
		    xpos = calc_offset("col", c, r, imgs)
		    ypos = calc_offset("row", c, r, imgs)
		    imgs_pos[r][c] = (xpos, ypos)
    return imgs_pos

def calc_offset(kind, c, r, imgs):
	if (kind == "col"):
		x = 0
		for i in range(c):
			x += get_img_res(imgs[r][i])[0]
		return x + c * spacing
	if (kind == "row"):
		y = 0
		for i in range(r):
			y += get_img_res(imgs[i][c])[1]
		return y + r * spacing

def calc_text_pos(canvas_res, img_res, entries):
    cx,cy = canvas_res
    ix,iy = img_res
    X,Y = calc_img_pos(entries)
    txtpos = [0] * len(entries)
    
    i = 0
    for entry in entries:
        pos, orientation, text = resolve(entry)
        textsize = get_textsize(canvas_res,entry)
        if(pos[0] == "T"):
            ty = Y - (textpad + fontsize)
        elif(pos[0] == "B"):
            ty = Y + iy + textpad
        
        if(pos[0] == "T" or pos[0] == "B"):
            if(pos[1] == "L"):
                tx = X + textpad
            elif(pos[1] == "C"):
                tx = X + ix//2 - textsize//2
            elif(pos[1] == "R"):
                tx = X + ix - (textpad + textsize)

        if(pos[0] == "L"):
            tx = X - (textpad + textsize)
        elif(pos[0] == "R"):
            tx = X + ix + textpad
        if(pos[0] == "L" or pos[0] == "R"):
            if(pos[1] == "T"):
                ty = textpad
            elif(pos[1] == "C"):
                ty = Y + iy//2
            elif(pos[1] == "B"):
                ty = Y + iy - fontsize
                
        txtpos[i] = (tx,ty)
        i += 1
    return txtpos

# For vertical text
def calc_text_pos_v(canvas_res, img_res, entry):
    cx,cy = canvas_res
    ix,iy = img_res
    X,Y = calc_img_pos(entries)
    
    pos, orientation, text = resolve(entry)
    textsize = get_textsize(canvas_res,entry)
    ty = textpad
    
    if(pos[0] == "L"):        
        if(pos[1] == "T"):
            tx = iy - (textpad + textsize)
        elif(pos[1] == "C"):
            tx = iy//2 - textsize//2
        elif(pos[1] == "B"):
            tx = textpad
        # past position
        tpx = X - textborder
        tpy = Y
        
    
    if(pos[0] == "R"):        
        if(pos[1] == "B"):
            tx = iy - (textpad + textsize)
        elif(pos[1] == "C"):
            tx = iy//2 - textsize//2
        elif(pos[1] == "T"):
            tx = textpad
        tpx = X + textborder + fontsize
        tpy = Y
    
    return (tx,ty),(tpx,tpy)

def get_textsize(canvas_res,entry):
    canvas = new_canvas(canvas_res)
    text = resolve(entry)[2]
    font = ImageFont.truetype(font_location, fontsize)
    draw = ImageDraw.Draw(canvas)
    return int(draw.textsize(text, font=font)[0])

def load_images(args, rows, cols):
    imgs = [ ([0] * cols) for row in range(rows) ]
    for i in range(rows):
        for j in range(cols):
            img_idx = cols*i + j
            if ( img_idx < len(args)-1 ):
                im = str(args[img_idx])
                imgs[i][j] = Image.open(im).convert(cm)
        
    return imgs
        
def draw_text(canvas, canvas_res, img_res, txtpos, entries):
    for i in range(len(entries)):
        pos, ori, text = resolve(entries[i])
        if ( ori == "h"): # horizontal text
            draw = ImageDraw.Draw(canvas)
            font = ImageFont.truetype(font_location, fontsize)
            draw.multiline_text(txtpos[i], text, font=font, fill='black')
        elif ( ori == "v"): # vertical text
            (tx,ty),(tpx,tpy) = calc_text_pos_v(canvas_res,img_res,entries[i])
            # Create text on transparent background and rotate. Resize for nicer text.
            img_res_scale = (img_res[1]*scale, img_res[1]*scale) # square from y-side to get sensible rotation
            v_canvas = Image.new('L', img_res_scale)
            v_draw = ImageDraw.Draw(v_canvas)
            font = ImageFont.truetype(font_location, fontsize*scale)
            v_draw.multiline_text((tx*scale,ty*scale), text, font=font, fill='white')

            rotation_degrees = 90
            v_canvas = v_canvas.rotate(rotation_degrees, expand=1)
            v_canvas = v_canvas.resize(img_res, Image.ANTIALIAS)
            colorization = ImageOps.colorize( v_canvas, (255, 255, 255),(0, 0, 0))   
            
            canvas.paste(colorization, (tpx,tpy), v_canvas)


#%%
# Option Parsing
parser = OptionParser(description="Figure creator.", usage="usage: %prog <in1> [<in2> ...] <dst.type>")
parser.add_option("-c", dest="colormode", 
		  help="Color mode.", default="RGBA")
parser.add_option("--fontsize", dest="fontsize", 
		  help="Fontsize.", default=int(192/3))
parser.add_option("--font", dest="font", 
		  help="Font.", default="/usr/share/fonts/opentype/linux-libertine/LinBiolinum_R")
parser.add_option("--fontcolor", dest="fontcolor", 
		  help="Fontcolor (R,G,B).", default="0,0,0")
parser.add_option("--tile", dest="tile", 
		  help="Tile 'rows x cols'.", default="1x1")
parser.add_option("-t", dest="entries", 
		  help="Position and orientation. E.g. 'TLv:Dummy, ...'<< for TopLeft & vertical text 'Dummy'")
parser.add_option("--textborder", dest="textborder", 
		  help="Textborder size", default=int(192/2))
parser.add_option("--textpad", dest="textpad", 
		  help="Textpad", default=int(192/300))
parser.add_option("--spacing", dest="spacing", 
		  help="Spacing", default=int(192/30))
parser.add_option("--resize", dest="resize",
		  help="Resize x:px:Type or y:px:Type. Type=iso or crop", default="x:-1:iso")

(options, args) = parser.parse_args() 

cm = str(options.colormode)
fontsize = int(options.fontsize)
font_location = str(options.font)
font = ImageFont.truetype(font_location, fontsize)
textborder = int((options.textborder))
textpad = (options.textpad) * textborder
spacing = int((options.spacing))

entries = str(options.entries)
entries = [str(t) for t in entries.split(", ")]

tile = str(options.tile)
rows,cols = [int(t) for t in tile.split("x")]

fontcolor_string = str(options.fontcolor)
fontcolorR,fontcolorG,fontcolorB = [int(f) for f in fontcolor_string.split(",")]
fontcolor = (fontcolorR,fontcolorG,fontcolorB)
resize = str(options.resize)
resize = [str(r) for r in resize.split(":")]
resize = (resize[0], int(resize[1]), resize[2])

#%% Start here
if( rows*cols > 1 ):
    pasteText = False
    assert(len(entries)==1), "Tile and Text cannot be combined"
elif( resize[1] > 0 ):
    pasteText = False
else:
    pasteText = True
# Load images in array
imgs = load_images(args, rows, cols)
img_res = get_img_res(imgs[0][0])

if(pasteText):
    img_pos = calc_img_pos(entries)
    canvas_res = calc_canvas_res(img_res,entries)
    canvas = new_canvas(canvas_res)
    txtpos = calc_text_pos(canvas_res,img_res,entries)
    canvas.paste(imgs[0][0],img_pos)
    draw_text(canvas, canvas_res, img_res, txtpos, entries)
elif(resize[1] > 0):
	x,y = get_img_res(imgs[0][0])
	if(resize[0] == "x"):
		xnew = int(resize[1])
		factor = xnew/x
		if(resize[2] == "crop"):
			ynew = y
		else:
			ynew = int(factor * y)

	elif(resize[0] == "y"):
		ynew = int(resize[1])
		factor = ynew/y
		if(resize[2] == "crop"):
			xnew = x
		else:
			xnew = int(factor * x)
	img_res_new = (xnew,ynew)
	img_resize(imgs[0][0], img_res_new)
	canvas = new_canvas(img_res_new)
	canvas.paste(imgs[0][0],(0,0))
else: # Tile
    canvas_res = calc_canvas_res_tile(imgs, rows, cols)
    img_pos = calc_img_pos_tile(imgs, rows, cols)

    canvas = new_canvas(canvas_res)
    for c in range(cols):
        for r in range(rows):
            canvas.paste(imgs[r][c],img_pos[r][c])

canvas.save(args[-1], dpi=dpi)
