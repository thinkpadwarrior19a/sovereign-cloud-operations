"""Strip 'Figure X.Y — ' prefix from all image alt texts and fix Figure 2.1 caption."""
import re
import glob
import os

book_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'book')
pattern = re.compile(r'!\[Figure\s+\d+\.\d+\s*—\s*')
total = 0

for md_file in sorted(glob.glob(os.path.join(book_dir, '*.md'))):
    with open(md_file, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content, count = pattern.subn('![', content)

    if count > 0:
        with open(md_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"  {os.path.basename(md_file)}: {count} replacements")
        total += count

print(f"\nTotal: {total} figure caption prefixes removed")

# Now fix the specific Figure 2.1 caption
ch2 = os.path.join(book_dir, '02_chapter_economics_ai_ops.md')
with open(ch2, 'r', encoding='utf-8') as f:
    content = f.read()

old = '![The operational cost iceberg]'
new = '![The hidden costs of multi-cloud operations]'
if old.lower() in content.lower():
    # Case-insensitive find and replace
    idx = content.lower().find(old.lower())
    content = content[:idx] + new + content[idx+len(old):]
    with open(ch2, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"\nFixed Figure 2.1 caption: '{old}' -> '{new}'")
else:
    # Try finding it after the prefix was stripped
    import re as re2
    m = re2.search(r'!\[.*?[Oo]perational [Cc]ost [Ii]ceberg.*?\]', content)
    if m:
        content = content[:m.start()] + new + content[m.end():]
        with open(ch2, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\nFixed Figure 2.1 caption: '{m.group()}' -> '{new}'")
    else:
        print(f"\nWARNING: Could not find Figure 2.1 caption to fix")
