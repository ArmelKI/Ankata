import os, sys, re, subprocess

max_iterations = 10
iteration = 0

while iteration < max_iterations:
    print(f"Iteration {iteration+1}")
    result = subprocess.run(['dart', 'analyze'], capture_output=True, text=True)
    out = result.stdout + result.stderr
    
    errors = [line for line in out.split('\n') if ('const_eval_method_invocation' in line or 'non_constant_list_element' in line or 'non_constant_map_element' in line or 'non_constant_set_element' in line or 'invalid_annotation_constant_value' in line or 'const_with_non_constant_argument' in line or 'const_with_non_type' in line or 'const_constructor_param_type_mismatch' in line or 'list_element_type_not_assignable' in line or 'map_value_type_not_assignable' in line)]
    
    if not errors:
        print("No more constant-related errors found.")
        break
        
    for line in set(errors):
        parts = line.strip().split(' - ')
        if len(parts) >= 2:
            file_info = parts[1]
            try:
                file_path, line_num_str, col_str = file_info.split(':')
                line_num = int(line_num_str) - 1
                
                with open(file_path, 'r', encoding='utf-8') as f:
                    file_lines = f.readlines()
                
                for i in range(line_num, max(-1, line_num - 10), -1):
                    if 'const ' in file_lines[i]:
                        # Using regex to ensure we only remove keyword 'const '
                        # and not just part of a string
                        new_line = re.sub(r'\bconst\s+', '', file_lines[i], count=1)
                        if new_line != file_lines[i]:
                            file_lines[i] = new_line
                            break
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(file_lines)
            except Exception as e:
                print("Failed to parse:", line, e)
                
    iteration += 1

