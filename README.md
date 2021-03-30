# CFB
Convert Folders to Books


# What it does
- Look only for directories containing images/book pages.
- Fix page numbers.
- Archive the folders with images to zip files
- Remove original folders
- Rename zip files to CBZ files.

# Documentation
I had a folder structure of comic books and didn't feel like manually archiving each one.
It only takes the folders that contains even a single image file and converts that folder.
The filter can be extended if you want it to archive folders that contain different files.

Main Folder
├── FolderToConvert
|         ├── Page01.jpg
|         ├── Page02.jpg
|         └── ...
├── Folder
|         └── FolderToConvert 
|                   ├── Page01.jpg
|                   ├── Page02.jpg
|                   └── ...
└── Folder
          └── Folder 
                    └── FolderToConvert 
                              ├── Page01.jpg
                              ├── Page02.jpg
                              └── ...

# Fix Page numbering
If the filenames start out with 1.jpg, 2.jpg, ... but the amout of pages is that of 2+ digits. It will not order well for reading.
The script looks at how many pages there are and if the pagenumbers are correct based on that.

It's very simple and I have only anticipated the problems I encountered so far. What it can fix:

(In case the page count is 2 digits.).
1.jpg, 2.jpg, 3.jpg, ... --> 01.jpg, 02.jpg, 03.jpg, ...
BookTitle-1.jpg, BookTitle-2.jpg, BookTitle-3.jpg, ... --> BookTitle-01.jpg, BookTitle-02.jpg, BookTitle-03.jpg, ...
BookTitle-Volume-1-1.jpg, BookTitle-Volume-1-2.jpg, BookTitle-Volume-1-3.jpg, ... --> BookTitle-Volume-1-01.jpg, BookTitle-Volume-1-02.jpg, BookTitle-Volume-1-03.jpg, ...

# Rename to CBZ
You can change this or entirely remove this line of code if you don't need it to become a CBZ file.
