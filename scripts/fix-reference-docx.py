"""Modify the Pandoc reference.docx to use sans-serif fonts throughout."""
import sys
from docx import Document
from docx.shared import Pt, RGBColor
from docx.oxml.ns import qn

SANS_FONT = "Calibri"
MONO_FONT = "Consolas"
HEADING_COLOR = RGBColor(0x0F, 0x30, 0x57)

doc = Document(sys.argv[1])

# Update theme fonts to sans-serif
theme = doc.element.find('.//' + qn('a:theme'))
if theme is not None:
    for major in theme.findall('.//' + qn('a:majorFont')):
        latin = major.find(qn('a:latin'))
        if latin is not None:
            latin.set('typeface', SANS_FONT)
    for minor in theme.findall('.//' + qn('a:minorFont')):
        latin = minor.find(qn('a:latin'))
        if latin is not None:
            latin.set('typeface', SANS_FONT)

# Update all styles
for style in doc.styles:
    try:
        if style.font is not None:
            if style.name and ('Code' in style.name or 'Verbatim' in style.name
                              or 'Source' in style.name):
                style.font.name = MONO_FONT
                style.font.size = Pt(9)
            else:
                style.font.name = SANS_FONT

            # Style headings
            if style.name and 'Heading' in style.name:
                style.font.name = SANS_FONT
                style.font.bold = True
                style.font.color.rgb = HEADING_COLOR

            # TOC styles
            if style.name and style.name.startswith('TOC'):
                style.font.name = SANS_FONT

            # Caption style
            if style.name and 'Caption' in style.name:
                style.font.name = SANS_FONT
                style.font.italic = True
                style.font.size = Pt(10)
    except Exception:
        pass

# Update default paragraph font
try:
    default_style = doc.styles['Normal']
    default_style.font.name = SANS_FONT
    default_style.font.size = Pt(11)
except Exception:
    pass

# Set default font in document settings
rPrDefault = doc.element.find('.//' + qn('w:rPrDefault'))
if rPrDefault is not None:
    rPr = rPrDefault.find(qn('w:rPr'))
    if rPr is not None:
        rFonts = rPr.find(qn('w:rFonts'))
        if rFonts is not None:
            rFonts.set(qn('w:ascii'), SANS_FONT)
            rFonts.set(qn('w:hAnsi'), SANS_FONT)
            rFonts.set(qn('w:cs'), SANS_FONT)

doc.save(sys.argv[2])
print(f"Saved updated reference doc to {sys.argv[2]}")
