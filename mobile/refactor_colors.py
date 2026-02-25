import os
import re

# Color mappings
color_map = {
    'AppColors.white': 'Theme.of(context).colorScheme.surface',
    'AppColors.lightGray': 'Theme.of(context).scaffoldBackgroundColor',
    'AppColors.charcoal': 'Theme.of(context).colorScheme.onSurface',
    'AppColors.gray': 'Theme.of(context).colorScheme.onSurfaceVariant',
    'AppColors.border': 'ThemeThemeData.dividerColor', # Using raw AppColors.border is easier to map to Theme.of(context).dividerColor
}
color_map['AppColors.border'] = 'Theme.of(context).dividerColor'

# Recursively find all .dart files
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart') and file != 'app_theme.dart':
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # Simple replacements
            for old, new in color_map.items():
                # Replace exact matches
                content = content.replace(old, new)
            
            # Now we must remove 'const ' if it precedes an opening bracket or widget name that contains Theme.of
            # A simple heuristic: find 'const ' and if the following block up to ';' or ',' contains 'Theme.of', remove 'const '
            # Since this is hard with regex, maybe regex to remove 'const ' before widgets where Theme.of is used.
            # E.g. const Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface) -> Icon(...)
            # const Text('...', style: TextStyle(color: Theme.of(context)...)) -> Text(...)

            # Regex to find 'const [A-Z].*Theme.of' and replace with '[A-Z].*Theme.of'
            # We can use a loop to repeatedly remove 'const ' from lines containing Theme.of
            lines = content.split('\n')
            for i in range(len(lines)):
                if 'Theme.of' in lines[i] and 'const ' in lines[i]:
                    lines[i] = lines[i].replace('const ', '')
            
            content = '\n'.join(lines)

            # Some consts might span multiple lines, e.g.:
            # const SnackBar(
            #   backgroundColor: Theme.of(context).colorScheme.surface,
            
            # Let's remove ANY 'const ' that appears right before a widget that has Theme.of inside its parentheses.
            # Since that's hard, let's just use dart compile to find invalid consts and strip them.
            
            if content != original_content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated {path}")
