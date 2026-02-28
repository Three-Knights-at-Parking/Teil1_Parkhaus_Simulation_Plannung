#ifndef STORAGE_H
#define STORAGE_H

#define STORAGE_MAX_VALID_NUMBER 1

void print_storagescreen(void);
ui_state storage_menu(void);
void browse_directory(char* current_path);
void directory_options(char* dir_path);
void file_options(char* file_path);
void deleting_verification(char* object_path, char* object_type);
void print_file_to_terminal(char* path);
void delete_directory(char* path);
void delete_file(char* path);
//EntryList read_directory(char* path);   // ← Typ ggf. anpassen, generell ist Absprache mit @Luca nötig

#endif